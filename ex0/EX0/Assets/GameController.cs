using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameController : MonoBehaviour
{
    public static int FIELD_SIZE = 30; // Width and height of the game field
    public static float COLLISION_THRESHOLD = 1.5f; // Collision distance between food and player 
    public GameObject playerObject; // Reference to the Player GameObject
    public int score = 0;
    public GameObject cameraObject;
    private Vector3 offset;

    private GameObject food; // Represents the food in the game

    // Start is called before the first frame update
    void Start()
    {
        food = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        SpawnFood();
        //Calculate and store the offset value by getting the distance between the player's position and camera's position.
        offset = cameraObject.transform.position - playerObject.transform.position;
    }

    // Positions the food at a random location inside the field
    void SpawnFood()
    {
        int size = FIELD_SIZE / 2;
        Vector3 pos = new Vector3(Random.Range(-size, size), 0, Random.Range(-size, size));
        food.transform.position = pos;
    }

    // Update is called once per frame
    void Update()
    {
        if(Vector3.Distance(food.transform.position, playerObject.transform.position) < COLLISION_THRESHOLD)
        {
            score += 1;
            print("Score: " + score);
            SpawnFood();
        }
        // Set the position of the camera's transform to be the same as the player's, but offset by the calculated offset distance.
        cameraObject.transform.position = playerObject.transform.position + offset;
    }
}

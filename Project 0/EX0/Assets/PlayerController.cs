using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public float movementForce = 500; // Controls player movement power
    private Rigidbody body;


    // Start is called before the first frame update
    void Start()
    {
        body = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        // Implement movement logic here
        if (Input.GetKey(KeyCode.UpArrow))
        {
            body.AddForce((transform.position + Vector3.forward * movementForce) * Time.deltaTime);
        }
        else if (Input.GetKey(KeyCode.DownArrow))
        {
            body.AddForce((transform.position + Vector3.back * movementForce) * Time.deltaTime);
        }
        else if (Input.GetKey(KeyCode.RightArrow))
        {
            body.AddForce((transform.position + Vector3.right * movementForce) * Time.deltaTime);
        }
        else if (Input.GetKey(KeyCode.LeftArrow))
        {
            body.AddForce((transform.position + Vector3.left * movementForce) * Time.deltaTime);
        }
    }
}

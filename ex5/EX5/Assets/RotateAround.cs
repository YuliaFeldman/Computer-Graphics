using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateAround : MonoBehaviour
{
    public float rotationSpeed = 10.0f;
    public Vector3 targetPoint = Vector3.zero;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        transform.RotateAround(targetPoint, Vector3.up, rotationSpeed * 10 * Time.deltaTime);
    }
}

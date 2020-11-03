using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterAnimator : MonoBehaviour
{
    public TextAsset BVHFile; // The BVH file that defines the animation and skeleton
    public bool animate; // Indicates whether or not the animation should be running

    private BVHData data; // BVH data of the BVHFile will be loaded here
    private int currFrame = 0; // Current frame of the animation
    private float timer = 0f;


    // Start is called before the first frame update
    void Start()
    {
        BVHParser parser = new BVHParser();
        data = parser.Parse(BVHFile);
        CreateJoint(data.rootJoint, Vector3.zero);
    }

    // Returns a Matrix4x4 representing a rotation aligning the up direction of an object with the given v
    Matrix4x4 RotateTowardsVector(Vector3 v)
    {
        v.Normalize();
        float thetaX = 90 - Mathf.Atan2(v.y, v.z) * Mathf.Rad2Deg;
        Matrix4x4 rotationMatrixRx = MatrixUtils.RotateX(thetaX);
        float thetaZ = 90 - Mathf.Atan2(Mathf.Sqrt(Mathf.Pow(v.y, 2f) + Mathf.Pow(v.z, 2f)), v.x) * Mathf.Rad2Deg;
        Matrix4x4 rotationMatrixRz = MatrixUtils.RotateZ(-thetaZ);


        return rotationMatrixRx * rotationMatrixRz;
    }

    // Creates a Cylinder GameObject between two given points in 3D space
    GameObject CreateCylinderBetweenPoints(Vector3 p1, Vector3 p2, float diameter)
    {
        GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        Matrix4x4 t = MatrixUtils.Translate(Vector3.Lerp(p1, p2, 0.5f));
        Matrix4x4 r = RotateTowardsVector(p2 - p1);
        float y_size = (p2 - p1).magnitude / 2;
        Vector3 scale = new Vector3(diameter, y_size, diameter);
        Matrix4x4 s = MatrixUtils.Scale(scale);
        MatrixUtils.ApplyTransform(cylinder, t * r * s);


        return cylinder;
    }

    // Creates a GameObject representing a given BVHJoint and recursively creates GameObjects for it's child joints
    GameObject CreateJoint(BVHJoint joint, Vector3 parentPosition)
    {
        joint.gameObject = new GameObject(joint.name);
        GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        sphere.transform.parent = joint.gameObject.transform;
        Vector3 scale;
        
        if (joint.name == "Head")
        {
            scale = new Vector3(8, 8, 8);
        }
        else
        {
            scale = new Vector3(2, 2, 2);
        }
        MatrixUtils.ApplyTransform(sphere, MatrixUtils.Scale(scale));
        Matrix4x4 t = MatrixUtils.Translate(parentPosition + joint.offset);
        MatrixUtils.ApplyTransform(joint.gameObject, t);

        foreach (BVHJoint child in joint.children)
        {
            GameObject childObject = CreateJoint(child, joint.gameObject.transform.position);
            GameObject bone = CreateCylinderBetweenPoints(joint.gameObject.transform.position,
                                                          childObject.transform.position, 0.5f);
            bone.transform.parent = joint.gameObject.transform;
        }


        return joint.gameObject;
    }

    // Transforms BVHJoint according to the keyframe channel data, and recursively transforms its children
    private void TransformJoint(BVHJoint joint, Matrix4x4 parentTransform, float[] keyframe)
    {
        Matrix4x4 t, m;
         
        if (joint == data.rootJoint)
        {
            Vector3 position = new Vector3(keyframe[joint.positionChannels[0]], keyframe[joint.positionChannels[1]],
                keyframe[joint.positionChannels[2]]);
            t = MatrixUtils.Translate(position);
        }
        else
        {
            t = MatrixUtils.Translate(joint.offset); 
        }

        if (!joint.isEndSite)
        {
            Matrix4x4[] r_array = new Matrix4x4[3];
            r_array[joint.rotationOrder[0]] = MatrixUtils.RotateX(keyframe[joint.rotationChannels[0]]);
            r_array[joint.rotationOrder[1]] = MatrixUtils.RotateY(keyframe[joint.rotationChannels[1]]);
            r_array[joint.rotationOrder[2]] = MatrixUtils.RotateZ(keyframe[joint.rotationChannels[2]]);
            Matrix4x4 r = r_array[0] * r_array[1] * r_array[2];
            m = parentTransform * t * r;
        }
        else
        {
            m = parentTransform * t;
        }

        MatrixUtils.ApplyTransform(joint.gameObject, m);
        foreach (BVHJoint child in joint.children)
        {
            TransformJoint(child, m, keyframe);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (animate)
        {
            timer += Time.deltaTime;
            if(timer >= data.frameLength)
            {
                TransformJoint(data.rootJoint, Matrix4x4.identity, data.keyframes[currFrame]);
                currFrame += 1;
                timer = 0f;
            }
            if (currFrame == data.numFrames)
            {
                currFrame = 0;
            }
        }
    }
}

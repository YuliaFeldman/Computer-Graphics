using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class MeshSubdivider : MonoBehaviour
{
    public TextAsset QuadOBJFile; // OBJ file to be loaded
    private MeshFilter meshFilter;
    private QuadMeshData meshData;
    private QuadOBJParser parser;

    // Start is called before the first frame update
    void Start()
    {
        parser = new QuadOBJParser();
        meshFilter = GetComponent<MeshFilter>();
    }

    // Loads a given OBJ file, calculates its surface normals and displays it
    public void ShowMesh()
    {
        meshData = parser.Parse(QuadOBJFile);
        meshFilter.mesh = meshData.ToUnityMesh();
    }

    public void Subdivide()
    {
        meshData = CatmullClark.Subdivide(meshData);
        meshFilter.mesh = meshData.ToUnityMesh();
    }
}

[CustomEditor(typeof(MeshSubdivider))]
class MeshSubdividerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        if (GUILayout.Button("Show Mesh"))
        {
            var meshSubdivider = target as MeshSubdivider;
            meshSubdivider.ShowMesh();
        }

        if (GUILayout.Button("Subdivide"))
        {
            var meshSubdivider = target as MeshSubdivider;
            meshSubdivider.Subdivide();
        }
    }
}
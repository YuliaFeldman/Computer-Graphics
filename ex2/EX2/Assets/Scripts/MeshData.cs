using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;


public class MeshData
{
    public List<Vector3> vertices; // The vertices of the mesh 
    public List<int> triangles; // Indices of vertices that make up the mesh faces
    public Vector3[] normals; // The normals of the mesh, one per vertex

    // Class initializer
    public MeshData()
    {
        vertices = new List<Vector3>();
        triangles = new List<int>();
    }

    // Returns a Unity Mesh of this MeshData that can be rendered
    public Mesh ToUnityMesh()
    {
        Mesh mesh = new Mesh
        {
            vertices = vertices.ToArray(),
            triangles = triangles.ToArray(),
            normals = normals
        };

        return mesh;
    }

    // Calculates surface normals for each vertex, according to face orientation
    public void CalculateNormals()
    {
        normals = new Vector3[vertices.Count];
        
        for(int i = 0; i < vertices.Count; i++)
        {
            Vector3 temp = Vector3.zero;
            int count = 0;
           
            for (int j = 0; j < triangles.Count-2; j+=3)
            {
                if (triangles[j] == i || triangles[j + 1] == i || triangles[j + 2] == i)
                {
                    temp += Vector3.Cross((vertices[triangles[j]] - vertices[triangles[j + 2]]), (vertices[triangles[j + 1]] - vertices[triangles[j + 2]])).normalized;
                    count++;
                }
                
            }
            normals[i] = (temp / count).normalized;
        }
    }

    // Edits mesh such that each face has a unique set of 3 vertices
    public void MakeFlatShaded()
    {
            
             List<int> ntriangles = new List<int>();
             List<Vector3> nvertices = new List<Vector3>();
             for (int i = 0; i < triangles.Count; i++)
             {
                  nvertices.Add(vertices[triangles[i]]);
                  ntriangles.Add(i);
             }

             vertices = nvertices;
             triangles = ntriangles;
    }
    
  }
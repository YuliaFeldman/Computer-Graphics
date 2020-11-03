using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using UnityEngine;


public class CCMeshData
{
    public List<Vector3> points; // Original mesh points
    public List<Vector4> faces; // Original mesh quad faces
    public List<Vector4> edges; // Original mesh edges
    public List<Vector3> facePoints; // Face points, as described in the Catmull-Clark algorithm
    public List<Vector3> edgePoints; // Edge points, as described in the Catmull-Clark algorithm
    public List<Vector3> newPoints; // New locations of the original mesh points, according to Catmull-Clark
}

public class pointData
{
    public Vector3 f;
    public Vector3 r;
    public int n;
    public HashSet<int> visited;
}

public static class CatmullClark
{
    // Returns a QuadMeshData representing the input mesh after one iteration of Catmull-Clark subdivision.
    public static QuadMeshData Subdivide(QuadMeshData quadMeshData)
    {
        // Create and initialize a CCMeshData corresponding to the given QuadMeshData
        CCMeshData meshData = new CCMeshData();
        meshData.points = quadMeshData.vertices;
        meshData.faces = quadMeshData.quads;
        meshData.edges = GetEdges(meshData);
        meshData.facePoints = GetFacePoints(meshData);
        meshData.edgePoints = GetEdgePoints(meshData);
        meshData.newPoints = GetNewPoints(meshData);
   
       

        // Combine facePoints, edgePoints and newPoints into a subdivided QuadMeshData

        // Your implementation here...
        
      
        var quads = new List<Vector4>();
        var vertices = new List<Vector3>();
        var vertToIdx = getPointDict(meshData, vertices);
        var t = edges_dict(meshData);
        for (int i = 0; i < meshData.facePoints.Count; i ++)
        {
            var fp = vertToIdx[meshData.facePoints[i]];
            var points = meshData.faces[i];
            
            for(int p = 0; p < 4; p ++)
            {
                var np = vertToIdx[meshData.newPoints[(int)points[p]]];
                var next_point = (int) points[(p+1) % 4];
                var original_point_cur = (int) points[p];
                var key1 = new Vector2(i, original_point_cur);
                var key2 = new Vector2(i, next_point);
                var cur_original_edges = t[key1];
                var next_edges = t[key2];
                int right = 0;
                for(int idx1 = 0; idx1 < cur_original_edges.Count; idx1 ++)
                {
                    for (int idx2 = 0; idx2 < next_edges.Count; idx2 ++)
                    {
                        if(cur_original_edges[idx1] == next_edges[idx2])
                        {
                            right = idx1;
                            break;
                        }
                    }
                }

                var quad = new Vector4(fp, vertToIdx[meshData.edgePoints[(int)cur_original_edges[(right+1) % 2]]], np,
               vertToIdx[meshData.edgePoints[(int)cur_original_edges[right % 2]]]);

                quads.Add(quad);
            }
               
                         
            }
        
       
        return new QuadMeshData(vertices, quads);
    }


    //return the edges that touches a original point at specific face key = (face, point), value = list of edges (2)
    public static Dictionary<Vector2, List<int>> edges_dict(CCMeshData meshData)
    {
        var result = new Dictionary<Vector2,List<int>>();
        for(int i = 0; i < meshData.edges.Count; i++)
        {
            for(int f_idx = 2; f_idx < 4; f_idx ++)
            {
                var f = meshData.edges[i][f_idx];
                if(f == -1)
                {
                    continue;
                }
                for(int p_idx = 0; p_idx < 2; p_idx ++)
                {
                    var p = meshData.edges[i][p_idx];
                    var key = new Vector2(f, p);
                    if(!result.ContainsKey(key))
                    {
                        result[key] = new List<int>();
                    }
                    result[key].Add(i);

                }
            }
 

        }
        return result;
    }


 
    //return dictionary of the index for the new points
    public static Dictionary<Vector3, int> getPointDict(CCMeshData meshData, List<Vector3> vertices)
    {
        var dict = new Dictionary<Vector3, int>();
        var cur_idx = 0;
        for(int i = 0; i < meshData.facePoints.Count; i++)
        {
            vertices.Add(meshData.facePoints[i]);
            dict[meshData.facePoints[i]] = cur_idx;
            cur_idx++;
        }
        for (int i = 0; i < meshData.edgePoints.Count; i++)
        {
            vertices.Add(meshData.edgePoints[i]);
            dict[meshData.edgePoints[i]] = cur_idx;
            cur_idx++;
        }
        for (int i = 0; i < meshData.newPoints.Count; i++)
        {
            vertices.Add(meshData.newPoints[i]);
            dict[meshData.newPoints[i]] = cur_idx;
            cur_idx++;
        }

        return dict;
    }

    // Returns a list of all edges in the mesh defined by given points and faces.
    // Each edge is represented by Vector4(p1, p2, f1, f2)
    // p1, p2 are the edge vertices
    // f1, f2 are faces incident to the edge. If the edge belongs to one face only, f2 is -1
    public static List<Vector4> GetEdges(CCMeshData mesh)
    {
        Vec2Comparer c = new Vec2Comparer();
        Dictionary<Vector2, Vector4> edges = new Dictionary<Vector2, Vector4>(c);

        for (int i = 0; i < mesh.faces.Count; i++)
        {
            for (int j = 0; j < 3; j++)
            {
                Vector2 edgeVertices = new Vector2(mesh.faces[i][j], mesh.faces[i][j + 1]);
                addEdge(edgeVertices, edges, i);
            }
            //adding the last edge
            Vector2 edgeVertices1 = new Vector2(mesh.faces[i][3], mesh.faces[i][0]);
            addEdge(edgeVertices1, edges, i);
        }
        return edges.Values.ToList();
    }

    public static void addEdge(Vector2 edgeVertices, Dictionary<Vector2, Vector4> edges, int face)
    {
        if (edges.ContainsKey(edgeVertices))
        {
            Vector4 edge = edges[edgeVertices];
            edge[3] = face;
            edges[edgeVertices] = edge;
        }
        else
        {
            Vector4 edge = new Vector4(edgeVertices[0], edgeVertices[1], face, -1);
            edges[edgeVertices] = edge;
        }
    }

    public class Vec2Comparer : EqualityComparer<Vector2>
    {
        public override bool Equals(Vector2 v1, Vector2 v2)
        {
            if ((v1.x == v2.x && v1.y == v2.y) || (v1.x == v2.y && v1.y == v2.x))
            {
                return true;
            }
            return false;
        }

        public override int GetHashCode(Vector2 obj)
        {
            return 0;
        }
    }


    // Returns a list of "face points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetFacePoints(CCMeshData mesh)
    {
        List<Vector3> facePoints = new List<Vector3>();
        for (int i = 0; i < mesh.faces.Count; i++)
        {
            Vector3 facePoint = Vector3.zero;
            for (int j = 0; j < 4; j++)
            {
                facePoint += mesh.points[(int)mesh.faces[i][j]];
            }
            facePoint /= 4;
            facePoints.Add(facePoint);
        }
        return facePoints;
    }

    // Returns a list of "edge points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetEdgePoints(CCMeshData mesh)
    {
        List<Vector3> edgePoints = new List<Vector3>();
        for (int i = 0; i < mesh.edges.Count; i++)
        {
            Vector3 edgePoint = mesh.points[(int)mesh.edges[i][0]] +
               mesh.points[(int)mesh.edges[i][1]] +
               mesh.facePoints[(int)mesh.edges[i][2]];
            
            if(mesh.edges[i][3] != -1)
            {
                edgePoint += mesh.facePoints[(int)mesh.edges[i][3]];
                edgePoint /= 4;
            }
            else
            {
                edgePoint /= 3;
            }
            edgePoints.Add(edgePoint);
        }
        return edgePoints;
    }


    public static List<pointData> createList(int numPoints)
    {
        var result = new List<pointData>();
        for(int i = 0; i < numPoints; i ++)
        {
            var data = new pointData();
            data.f = Vector3.zero;
            data.r = Vector3.zero;
            data.n = 0;
            data.visited = new HashSet<int>();
            data.visited.Add(-1);
            result.Add(data);
        }
        return result;
    }

    // Returns a list of new locations of the original points for the given CCMeshData, as described in the CC algorithm 
    public static List<Vector3> GetNewPoints(CCMeshData mesh)
    {
        var dataPoints = createList(mesh.points.Count);
       // foreach(var edge in mesh.edges)
        for(int j = 0; j < mesh.edges.Count; j ++)
        {
            int p1 = (int)mesh.edges[j][0];
            int p2 = (int)mesh.edges[j][1];
            var midEdge = (mesh.points[p1] + mesh.points[p2]) / 2;
            dataPoints[p1].r += midEdge;
            dataPoints[p2].r += midEdge;
            for (int i = 2; i < 4; i++)
            {
             
                int face = (int)mesh.edges[j][i];
           
                if (!dataPoints[p1].visited.Contains(face))
                {
                    dataPoints[p1].visited.Add(face);
                    dataPoints[p1].f += mesh.facePoints[face];
                    dataPoints[p1].n++;

                }
                if (!dataPoints[p2].visited.Contains(face))
                {
                    dataPoints[p2].visited.Add(face);
                    dataPoints[p2].f += mesh.facePoints[face];
                    dataPoints[p2].n++;

                }

            }

        }

        var newPoints = new List<Vector3>();
        for(int i = 0; i < mesh.points.Count; i ++)
        {
            var p = dataPoints[i];
            var position = (p.f) / p.n + 2 * p.r / p.n + (p.n - 3) * mesh.points[i];
            position /= p.n;
            newPoints.Add(position);
        }

        return newPoints;
    }
}
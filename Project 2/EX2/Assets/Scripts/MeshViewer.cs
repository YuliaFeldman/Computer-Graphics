using UnityEditor;
using UnityEngine;

public class MeshViewer : MonoBehaviour
{
    public TextAsset OBJFile; // OBJ file to be loaded
    public bool isFlatShaded; // Should loaded mesh be flat shaded
    private OBJParser parser; // OBJ file format Parser 
    private MeshData meshData; // Parsed OBJ data
    private MeshFilter meshFilter; // MeshFilter reference, used to display a Unity Mesh


    // Start is called before the first frame update
    void Start()
    {
        parser = new OBJParser();
        meshFilter = GetComponent<MeshFilter>();
    }

    // Loads a given OBJ file, calculates its surface normals and displays it
    public void ShowMesh()
    {
        meshData = parser.parse(OBJFile);

        if (isFlatShaded)
        {
            meshData.MakeFlatShaded();
        }
        meshData.CalculateNormals();

        meshFilter.mesh = meshData.ToUnityMesh();
    }
}

// A custom inspector UI for this class 
[CustomEditor(typeof(MeshViewer))]
class MeshViewerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        if (GUILayout.Button("Show Mesh"))
        {
            var meshViewer = target as MeshViewer;
            meshViewer.ShowMesh();
        }
    }
}
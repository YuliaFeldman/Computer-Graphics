using System.Collections;
using System.Collections.Generic;
using UnityEngine;

 public enum Scene
 {
    scene0,
    scene1,
    scene2,
    scene3,
    scene4
 };


public class RayTracer : MonoBehaviour
{
    public Scene scene;
    [Range(0, 10)]
    public int bounceLimit = 3;

    public ComputeShader shader;
    public Texture skyboxTexture;
    public Light directionalLight;

    private RenderTexture renderTarget;
    private Camera cam;


    private void Awake()
    {
        cam = GetComponent<Camera>();
    }


    private void SetShaderParameters()
    {
        shader.SetMatrix("_CamToWorld", cam.cameraToWorldMatrix);
        shader.SetMatrix("_CamInverseProjection", cam.projectionMatrix.inverse);
        shader.SetTexture(0, "_SkyboxTexture", skyboxTexture);
        Vector3 l = directionalLight.transform.forward;
        shader.SetVector("_DirectionalLight", new Vector4(l.x, l.y, l.z, directionalLight.intensity));
        shader.SetInt("_BounceLimit", bounceLimit);
        shader.SetInt("_SceneIndex", (int)scene);

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        SetShaderParameters();
        Render(destination);
    }

    private void Render(RenderTexture destination)
    {
        // Make sure we have a current render target
        InitRenderTexture();
        // Set the target and dispatch the compute shader
        shader.SetTexture(0, "Result", renderTarget);
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        shader.Dispatch(0, threadGroupsX, threadGroupsY, 1);
        // Blit the result texture to the screen
        Graphics.Blit(renderTarget, destination);
    }


    private void InitRenderTexture()
    {
        if (renderTarget == null || renderTarget.width != Screen.width || renderTarget.height != Screen.height)
        {
            // Release render texture if we already have one
            if (renderTarget != null)
                renderTarget.Release();
            // Get a render target for Ray Tracing
            renderTarget = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            renderTarget.enableRandomWrite = true;
            renderTarget.Create();
        }
    }

}

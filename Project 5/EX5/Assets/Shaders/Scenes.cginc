// Defines an empty scene
RayHit intersectScene0(Ray ray)
{
    RayHit bestHit = CreateRayHit();
    return bestHit;
}

// Defines a scene with one diffuse sphere
RayHit intersectScene1(Ray ray)
{
    Material diffuse = CreateMaterial(0.7, 0);

    RayHit bestHit = CreateRayHit();
    intersectSphere(ray, bestHit, diffuse, float4(0, 1, 0, 1));
    return bestHit;
}

// Defines a scene with one diffuse sphere and a floor plane
RayHit intersectScene2(Ray ray)
{
    Material diffuse = CreateMaterial(0.7, 0);
    Material diffuseRed = CreateMaterial(float3(0.8, 0.2, 0.2), 0);

    RayHit bestHit = CreateRayHit();
    intersectPlane(ray, bestHit, diffuse, float3(0, 0, 0), float3(0, 1, 0));
    intersectSphere(ray, bestHit, diffuseRed, float4(0, 1, 0, 1));
    return bestHit;
}


// Defines a scene with various diffuse and reflective objects
RayHit intersectScene3(Ray ray)
{
    Material diffuse1 = CreateMaterial(float3(0.14, 0.43, 0.84), 0);
    Material diffuse2 = CreateMaterial(float3(0.27, 0.51, 0.56), 0);
    Material diffuse3 = CreateMaterial(float3(0.55, 0.30, 0.61), 0);
    Material mirror = CreateMaterial(0, 0.7);
    Material mirrorHalf = CreateMaterial(0.5, 0.5);
    Material floor = CreateMaterial(float3(0.95, 0.85, 0.7), 0.15);
    Material gold = CreateMaterial(0, float3(1.0f, 0.78f, 0.34f));

    RayHit bestHit = CreateRayHit();
    intersectPlane(ray, bestHit, floor, float3(0, 0, 0), float3(0, 1, 0));

    // Construct a pyramid from triangles
    float3 p0 = float3(0, 1.5, 0);
    float3 p1 = float3(1, 0, 1);
    float3 p2 = float3(1, 0, -1);
    float3 p3 = float3(-1, 0, -1);
    float3 p4 = float3(-1, 0, 1);

    intersectTriangle(ray, bestHit, mirrorHalf, p1, p2, p0);
    intersectTriangle(ray, bestHit, mirrorHalf, p2, p3, p0);
    intersectTriangle(ray, bestHit, mirrorHalf, p3, p4, p0);
    intersectTriangle(ray, bestHit, mirrorHalf, p4, p1, p0);

    intersectSphere(ray, bestHit, diffuse1, float4(1.3, _SinTime.w*0.5 + 1, 1.1, 0.2));
    intersectSphere(ray, bestHit, diffuse2, float4(-1.5, _CosTime.w*0.6 + 1, 1.2, 0.3));
    intersectSphere(ray, bestHit, diffuse3, float4(0.5, _SinTime.y + 1.5, -1.4, 0.25));
    intersectSphere(ray, bestHit, gold, float4(0, 2.25, 0, 0.75));

    return bestHit;
}


// Defines a scene with diffuse, reflective and refractive spheres
RayHit intersectScene4(Ray ray)
{
    Material gold = CreateMaterial(0, float3(1.0f, 0.78f, 0.34f));
    Material diffuse = CreateMaterial(float3(0.27, 0.51, 0.56), 0);
    Material black = CreateMaterial(0.9, 0.2);
    Material white = CreateMaterial(0.2, 0.2);
    Material water = CreateRefractiveMaterial(1.3);

    RayHit bestHit = CreateRayHit();
    intersectPlaneCheckered(ray, bestHit, black, white, float3(0, 0, 0), float3(0, 1, 0));

    intersectSphere(ray, bestHit, diffuse, float4(0, 1, 0, 1));
    intersectSphere(ray, bestHit, gold, float4(-1, 0.5, 1.5, 0.5));
    intersectSphere(ray, bestHit, water, float4(0.9, 0.4, 1.2, 0.4));
    return bestHit;
}
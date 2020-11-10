// Checks for an intersection between a ray and a sphere
// The sphere center is given by sphere.xyz and its radius is sphere.w
void intersectSphere(Ray ray, inout RayHit bestHit, Material material, float4 sphere)
{
    float B = 2 * dot((ray.origin - sphere.xyz), ray.direction);
    float C = dot((ray.origin - sphere.xyz), (ray.origin - sphere.xyz)) - pow(sphere.w, 2);
    float D = pow(B, 2) - 4 * C;
    float t;
    float hit = 0;

    if (D > 0)
    {
        float t0 = (-B + pow(D, 0.5)) / 2;
        float t1 = (-B - pow(D, 0.5)) / 2;
        t = min(t0, t1);
        if (t < 0)
        {
            if (t0 > 0)
            {
                t = t0;
                if (t < bestHit.distance)
                {
                    hit = 1;
                }
                

            }
            if (t1 > 0)
            {
                t = t1;
                if (t < bestHit.distance)
                {
                    hit = 1;
                }
            }
        }
        else
        {
            if (t < bestHit.distance)
            {
                hit = 1;
            }
        }
       
    }
    if(D == 0)
    {
        t = -B / 2;
        if (t > 0)
        {
            if (t < bestHit.distance)
            {
                hit = 1;
            }
        }
        
    }
    if (hit)
    {
        float3 ray_t = ray.origin + (ray.direction * t);
        float3 normal = normalize(ray_t  - sphere.xyz);
        bestHit.distance = t;
        bestHit.position = ray_t;
        bestHit.normal = normal;
        bestHit.material = material;
    }
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
void intersectPlane(Ray ray, inout RayHit bestHit, Material material, float3 c, float3 n)
{
    float rn = dot(ray.direction, n);
    if (rn)
    {
        float t = dot(-(ray.origin - c), n) / rn;
        if (t > 0)
        {
            if (t < bestHit.distance)
            {
                float3 ray_t = ray.origin + ray.direction * t;
                bestHit.distance = t;
                bestHit.position = ray_t;
                bestHit.normal = n;
                bestHit.material = material;

            }


        }


    }
    
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
// The material returned is either m1 or m2 in a way that creates a checkerboard pattern 
void intersectPlaneCheckered(Ray ray, inout RayHit bestHit, Material m1, Material m2, float3 c, float3 n)
{
    float rn = dot(ray.direction, n);
    if (rn)
    {
        float t = dot(-(ray.origin - c), n) / rn;
        if (t > 0)
        {
            if (t < bestHit.distance)
            {
                float3 ray_t = ray.origin + ray.direction * t;
                Material m = m1;

                float f = (floor(2 * ray_t.x) + floor(2 * ray_t.z)) % 2;
                if (f)
                {
                    m = m2;
                }
                bestHit.distance = t;
                bestHit.position = ray_t;
                bestHit.normal = n;
                bestHit.material = m;

            }

        }


    }
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c)
{
    float3 n = normalize(cross(a - c, b - c));
    float rn = dot(ray.direction, n);
    if (rn)
    {
        float t = dot(-(ray.origin - c), n) / rn;
        if (t > 0)
        {
            if (t < bestHit.distance)
            {
                float3 ray_t = ray.origin + ray.direction * t;
                if (dot(cross((b - a), (ray_t - a)), n) >= 0 &&     //if ray_t is inside the triangle
                    dot(cross((c - b), (ray_t - b)), n) >= 0 &&
                    dot(cross((a - c), (ray_t - c)), n) >= 0)
                {
                    bestHit.distance = t;
                    bestHit.position = ray_t;
                    bestHit.normal = n;
                    bestHit.material = material;
                }

            }

        }
    }
}
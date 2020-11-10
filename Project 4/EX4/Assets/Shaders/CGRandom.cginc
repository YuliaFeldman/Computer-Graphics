#ifndef CG_RANDOM_INCLUDED
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
#define CG_RANDOM_INCLUDED

// Returns a psuedo-random float between -1 and 1 for a given float c
float random(float c)
{
    return -1.0 + 2.0 * frac(43758.5453123 * sin(c));
}

// Returns a psuedo-random float2 with componenets between -1 and 1 for a given float2 c 
float2 random2(float2 c)
{
    c = float2(dot(c, float2(127.1, 311.7)), dot(c, float2(269.5, 183.3)));

    float2 v = -1.0 + 2.0 * frac(43758.5453123 * sin(c));
    return v;
}

// Returns a psuedo-random float3 with componenets between -1 and 1 for a given float3 c 
float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0*j);
    j *= .125;
    r.x = frac(512.0*j);
    j *= .125;
    r.y = frac(512.0*j);
    r = -1.0 + 2.0 * r;
    return r.yzx;
}

// Interpolates a given array v of 4 float2 values using bicubic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
//
// [0]=====o==[1]
//         |
//         t
//         |
// [2]=====o==[3]
//
float bicubicInterpolation(float2 v[4], float2 t)
{
    float2 u = t * t * (3.0 - 2.0 * t); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 4 float2 values using biquintic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
float biquinticInterpolation(float2 v[4], float2 t)
{
    float2 u = t * t * t * (10.0 -15.0 * t + 6.0 * t * t); // Quintic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 8 float3 values using triquintic interpolation
// at the given ratio t (a float3 with components between 0 and 1)
float triquinticInterpolation(float3 v[8], float3 t)
{
    float3 u = t * t * t * (10.0 - 15.0 * t + 6.0 * t * t); // Quintic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);
    float x3 = lerp(v[4], v[5], u.x);
    float x4 = lerp(v[6], v[7], u.x);
    
    //Interpolate in the y direction
    float y1 = lerp(x1, x2, u.y);
    float y2 = lerp(x3, x4, u.y);

    //Interpolate in the z direction

    return lerp(y1, y2, u.z);
}

// Returns the value of a 2D value noise function at the given coordinates c
float value2d(float2 c)
{
    float2 corner1 = float2(ceil(c.x), floor(c.y));
    float2 corner2 = float2(ceil(c.x), ceil(c.y));
    float2 corner3 = float2(floor(c.x), floor(c.y));
    float2 corner4 = float2(floor(c.x), ceil(c.y));
    float2 rand1 = (random2(corner1));
    float2 rand2 = (random2(corner2));
    float2 rand3 = (random2(corner3));
    float2 rand4 = (random2(corner4));
    float2 v[4] = { rand3, rand1, rand4, rand2 };
    return bicubicInterpolation(v, frac(c));
    
}

// Returns the value of a 2D Perlin noise function at the given coordinates c
float perlin2d(float2 c)
{   
    float2 corner1 = float2(ceil(c.x), floor(c.y));
    float2 corner2 = float2(ceil(c.x), ceil(c.y));
    float2 corner3 = float2(floor(c.x), floor(c.y));
    float2 corner4 = float2(floor(c.x), ceil(c.y));
    float2 rand1 = (random2(corner1));
    float2 rand2 = (random2(corner2));
    float2 rand3 = (random2(corner3));
    float2 rand4 = (random2(corner4));
    float2 dist1 = corner1 - c;
    float2 dist2 = corner2 - c;
    float2 dist3 = corner3 - c;
    float2 dist4 = corner4 - c;
    float2 dot1 = dot(rand1, dist1);
    float2 dot2 = dot(rand2, dist2);
    float2 dot3 = dot(rand3, dist3);
    float2 dot4 = dot(rand4, dist4);
    float2 v[4] = { dot3, dot1, dot4, dot2 };
    return biquinticInterpolation(v, frac(c));

}

// Returns the value of a 3D Perlin noise function at the given coordinates c
float perlin3d(float3 c)
{                    
    float3 corner1 = float3(ceil(c.x), floor(c.y), ceil(c.z));
    float3 corner2 = float3(ceil(c.x), floor(c.y), floor(c.z));
    float3 corner3 = float3(ceil(c.x), ceil(c.y), ceil(c.z));
    float3 corner4 = float3(ceil(c.x), ceil(c.y), floor(c.z));
    float3 corner5 = float3(floor(c.x), floor(c.y), ceil(c.z));
    float3 corner6 = float3(floor(c.x), floor(c.y), floor(c.z));
    float3 corner7 = float3(floor(c.x), ceil(c.y), ceil(c.z));
    float3 corner8 = float3(floor(c.x), ceil(c.y), floor(c.z));
    
    float3 rand1 = random3(corner1);
    float3 rand2 = random3(corner2);
    float3 rand3 = random3(corner3);
    float3 rand4 = random3(corner4);
    float3 rand5 = random3(corner5);
    float3 rand6 = random3(corner6);
    float3 rand7 = random3(corner7);
    float3 rand8 = random3(corner8);

    float3 dist1 = corner1 - c;
    float3 dist2 = corner2 - c;
    float3 dist3 = corner3 - c;
    float3 dist4 = corner4 - c;
    float3 dist5 = corner5 - c;
    float3 dist6 = corner6 - c;
    float3 dist7 = corner7 - c;
    float3 dist8 = corner8 - c;

    float3 dot1 = dot(rand1, dist1);
    float3 dot2 = dot(rand2, dist2);
    float3 dot3 = dot(rand3, dist3);
    float3 dot4 = dot(rand4, dist4);
    float3 dot5 = dot(rand5, dist5);
    float3 dot6 = dot(rand6, dist6);
    float3 dot7 = dot(rand7, dist7);
    float3 dot8 = dot(rand8, dist8);

    float3 v[8] = { dot5, dot1, dot7, dot3, dot6, dot2, dot8, dot4 };
   
    return triquinticInterpolation(v, frac(c));
}


#endif // CG_RANDOM_INCLUDED

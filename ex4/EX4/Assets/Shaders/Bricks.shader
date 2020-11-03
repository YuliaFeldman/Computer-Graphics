Shader "CG/Bricks"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(-100, 100)) = 40
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;
                uniform sampler2D _HeightMap;
                uniform float4 _HeightMap_TexelSize;
                uniform float _BumpScale;

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv: TEXCOORD0;
                    float3 normal: NORMAL;
                    float4 vertex: TEXCOORD1;
                    float4 tangent: TANGENT;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.uv = input.uv;
                    output.normal = input.normal;
                    output.vertex = input.vertex;
                    output.tangent = input.tangent;
                    return output;
                }

                fixed4 frag(v2f input) : SV_Target
                {
                    fixed4 Albedo_color = tex2D(_AlbedoMap, input.uv);
                    fixed4 specularity = tex2D(_SpecularMap, input.uv);
                    float3 n = normalize(mul(unity_ObjectToWorld, normalize(input.normal)));

                    bumpMapData i;
                    i.normal = n;
                    i.tangent = mul(unity_ObjectToWorld, input.tangent);;
                    i.du = _HeightMap_TexelSize.x;
                    i.dv = _HeightMap_TexelSize.y;
                    i.uv = input.uv;
                    i.heightMap = _HeightMap;
                    i.bumpScale = _BumpScale/10000;
                    float3 new_n = getBumpMappedNormal(i);


                    float3 l = normalize(_WorldSpaceLightPos0);
                    float4 posWorld = mul(unity_ObjectToWorld, input.vertex);
                    float3 v = normalize(float4(_WorldSpaceCameraPos, 0) - posWorld);
                    fixed3 color = blinnPhong(new_n,  v,  l, _Shininess,
                        Albedo_color, specularity, _Ambient);
                    return fixed4(color,1);
                   
                }

            ENDCG
        }
    }
}

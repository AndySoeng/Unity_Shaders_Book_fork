Shader "Unity Shaders Book Learn/Chapter 6/HalfLambert Pixel-Level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color)= (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex :POSITION;
                float3 normal :NORMAL;
            };

            struct v2f
            {
                float4 pos :SV_POSITION;
                float3 worldNormal :TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                //Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                //将法线从模型空间转换到世界空间
                //Transform the normal from object space to world space
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                //获取环境光颜色
                //Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //归一化世界空间法线
                //Get the normal in world space
                fixed3 worldNormal = normalize(i.worldNormal);

                //获取世界空间下的光照方向单位向量
                //Get the light direction in world space
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                //Compute diffuse term
                fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                //将漫反射颜色与环境光叠加
                fixed3 color = ambient + diffuse;

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
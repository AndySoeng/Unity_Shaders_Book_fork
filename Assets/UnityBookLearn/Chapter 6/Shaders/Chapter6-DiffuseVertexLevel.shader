// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book Learn/Chapter 6/Diffuse Vertex-Level"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"= "ForwardBase"
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
                fixed3 color : COLOR;
            };

            v2f vert(a2v v)
            {
                v2f o;
                //将顶点从模型空间转换到裁剪空间
                //Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                //获取环境光
                //Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                //将法线 从模型空间转换到世界空间
                //Transform the normal from object space to world space
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                 //等价上面转换法线的操作
                //fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);

                //获取世界空间下的光照方向
                //get the light direction in world space
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                //计算漫反射 C(diffuse)=C(light)*M(diffuse)*max(0,N*L)
                //Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                //将漫反射和环境光叠加到颜色上
                o.color = ambient + diffuse;

                return o;
            }

            fixed4 frag(v2f i) :SV_Target
            {
                return fixed4(i.color, 1);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
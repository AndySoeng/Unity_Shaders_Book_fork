Shader "Untiy Shaders Book Learn/Chapter 6/HalfLambert Pixel-Level"
{
    Properties
    {
        _Diffuse("Diffuse",Color) =(1,1,1,1)
        _Specular("Specular",Color) =(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))= 20
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
            #include "UnityCG.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos :TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                //Transform the vertex from object space to projection space
                o.vertex = UnityObjectToClipPos(v.vertex);

                //Transform the normal from object space to world space
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                //o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //Transform the vertex form object space to world space 
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                //Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //Transform the normal from object space to world space
                fixed3 worldNormal = normalize(i.worldNormal);
                //Get the light direction in world space
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                //Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                //用于高光反射中计算反射方向reflectDir，CG的reflect函数的入射方向要求是由光源指向交点处的，因此需要对worldLightDir取反后再传给reflect函数
                //get the reflect direction in world space
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                //通过_WorldSpaceCameraPos可以得到世界空间中的摄像机位置，再把顶点位置从模型空间变换到世界空间下，再通过和_WorldSpaceCameraPos相减即可得到世界空间下的视角方向
                //Get the view direction in world space
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                //等价
                //fixed3 viewDir= normalize(UnityWorldSpaceViewDir( i.worldPos.xyz));

                //Compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(viewDir, reflectDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
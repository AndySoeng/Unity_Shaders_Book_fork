Shader "Unity Shaders Book Learn/Chapter 10/Glass Refraction"
{
    Properties
    {
        _MainTex("Main Tex",2D)= "white"{}
        _BumpMap("Normal Map",2D) ="bump"{}
        _CubeMap("Environment Cubemap",Cube)="_Skybox"{}
        _Distortion("Distortion",Range(0,100))=10
        _RefractAmount("Refract Amount",Range(0,1))=1.0
    }
    SubShader
    {
        //We must be transparent , so other objects are drawn before this one
        Tags
        {
            "Queue"="Transparent" "RenderType"="Opaque"
        }

        //This pass grabs the screen behind the object into a texture
        //We can access the result in the next pass as _RefractionTex
        GrabPass
        {
            "_RefractionTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _CubeMap;
            float _Distortion;
            float _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 scrPos:TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 TtoW0:TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 :TEXCOORD4;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //得到对应被抓取的屏幕图像的采样坐标
                o.scrPos = ComputeGrabScreenPos(o.pos);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                //Get th normal in tangent space
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

                //Comput the offset in tangent space
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = i.scrPos.xy + offset;
                fixed3 refrColor = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

                //Convert the normal to world space
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                fixed3 reflDir = reflect(-worldViewDir, bump);
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                fixed3 reflColor = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb;

                fixed3 finalColor = reflColor * (1 - _RefractAmount) + refrColor * _RefractAmount;
                
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
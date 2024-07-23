Shader "Unity Shaders Book Learn/Chapter 13/Motion Blur With Depth Texture"
{
    Properties
    {
        _MainTex ("Base (RBG)", 2D) = "white" {}
        _BlurSize("Blur Size",Float) =0.5
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float4x4 _CurrentViewProjectionInverseMatrix;
        float4x4 _PreviousViewProjectionMatrix;
        half _BlurSize;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;

            #ifdef UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
            {
                o.uv_depth.y = 1 - o.uv_depth.y;
            }
            #endif

            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            //通过深度缓存获取像素的深度值
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            #ifdef UNITY_REVERSED_Z
            d = 1.0 - d;
            #endif

            //组合出当前像素的NDC坐标
            float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
            //通过当前视角投影的逆矩阵将NDC坐标进行转换
            float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
            //除w 得到世界空间坐标
            float4 worldPos = D / D.w;

            //当前像素的NDC坐标
            float4 currentPos = H;
            //通过世界坐标，和上一帧的视角投影矩阵变幻出上一帧的NDC坐标
            float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
            //通过除以 w 转换为非均匀点 [-1,1]。
            previousPos /= previousPos.w;

            //计算像素的速度
            half2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;

            //Demo
            float2 uv = i.uv;
            float4 c = tex2D(_MainTex, i.uv);
            uv += velocity * _BlurSize;
            for (int it = 1; it < 3; it++, uv += velocity * _BlurSize)
            {
                float4 currentColor = tex2D(_MainTex, uv);
                c += currentColor;
            }
            c /= 3;

            // 按不同的权重进行混合，改善模糊效果
            // float2 uv = i.uv;
            // float vecColRate[3] = {0.7, 0.2, 0.1};
            // float4 c = tex2D(_MainTex, i.uv) * vecColRate[0];;
            // uv += velocity * _BlurSize;
            // for (int it = 1; it < 3; it++, uv += velocity * _BlurSize)
            // {
            //     float4 currentColor = tex2D(_MainTex, uv);
            //     c += currentColor * vecColRate[it];
            // }
            return fixed4(c.rgb, 1);
        }
        ENDCG




        Pass
        {
            // No culling or depth
            Cull Off ZWrite Off ZTest Always

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    Fallback Off
}
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book Learn/Chapter 5/Simple Shader"
{
    Properties
    {
        //声明一个Color类型的属性
        _Color("Color Tint",Color)=(1,1,1,1)
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragment

            #include "UnityCG.cginc"

            //在CG代码中，我们需要定义一个与属性名称和类型都匹配的变量
            fixed4 _Color;


            //使用一个结构体来定义顶点着色器的输入
            struct a2v
            {
                // POSITION 语义告诉Unity，用模型空间的顶点坐标填充vertex变量
                float4 vertex: POSITION;
                //NORMAL 语义告诉Unity，用模型空间的法线填充normal变量
                float3 normal : NORMAL;
                //TEXCOORD0 语义告诉Unity，用模型空间的第一套纹理坐标填充texcoord变量
                float4 texcoord :TEXCOORD0;
            };

            //使用一个结构体来定义顶点着色器的输出
            struct v2f
            {
                //SV_POSITION 语义告诉Unity ,pos里包含了顶点在裁剪空间中的位置信息
                float4 pos:SV_POSITION;
                //COLOR0 语义可以用于存储颜色信息
                fixed3 color :COLOR0;
            };


            v2f vert(a2v v)
            {
                //声明输出结构
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //v.normal 包含了顶点的法线方向，其分量在[-1,1]
                //下面的代码把分量范围映射到了[0,1]
                //存储到o.color 传递给片源着色器
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);

                return o;
            }

            fixed4 fragment(v2f i) : SV_TARGET
            {
                fixed3 c = i.color;
                //使用_Color属性来控制输出颜色
                c *= _Color.rgb;
                // color 显示到屏幕上
                return fixed4(c, 1.0);
            }
            ENDCG
        }
    }
}
Shader "Unlit/WireframeTransparent"
{
    Properties
    {
        _Color ("Wireframe Color", Color) = (1,1,1,1)
        _FillColor ("Fill Color", Color) = (0,0,0,0)
        _Thickness ("Thickness", Range(0,0.5)) = 0.01

		[Toggle(HIDE_DIAGONALS)]
		_HideDiagonals("Hide Diagonals", Float) = 1
    }
    SubShader
    {
		
        Tags
		{
			"RenderType"="Transparent"
			"Queue" = "Overlay"
		}

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

			#define TRANSPARENCY_ON
			#pragma shader_feature_local HIDE_DIAGONALS

            #include "UnityCG.cginc"
			#include "WireframeBase.cginc"
            
            ENDCG
        }
    }
}

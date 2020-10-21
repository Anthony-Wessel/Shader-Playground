Shader "Unlit/WireframeOpaque"
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
			"RenderType"="Opaque"
		}

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag

			#pragma shader_feature_local HIDE_DIAGONALS

            #include "UnityCG.cginc"
			#include "WireframeBase.cginc"
            
            ENDCG
        }
    }
}

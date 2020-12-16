Shader "Unlit/Tessellation"
{
	Properties
	{
		_Color("Wireframe Color", Color) = (1,1,1,1)
		_FillColor("Fill Color", Color) = (0,0,0,0)
		_Thickness("Thickness", Range(0,0.5)) = 0.01
	}
	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
		}

		Pass
		{
			CGPROGRAM

			#pragma vertex MyTessellationVertexProgram
			#pragma geometry geom
			#pragma hull MyHullProgram
			#pragma domain MyDomainProgram
			#pragma fragment frag

			#pragma target 4.6

			#include "UnityCG.cginc"
			

			struct v2g
			{
				float4 vertex : SV_POSITION;
				float4 localPos : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			struct g2f
			{
				float4 vertex : POSITION;
				float3 dist : TEXCOORD2;
			};

			fixed4 _Color;
			fixed4 _FillColor;
			fixed _Thickness;

			struct TessellationControlPoint
			{
				float4 vertex : POSITION;
				float4 localPos : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			TessellationControlPoint vert(TessellationControlPoint v)
			{
				TessellationControlPoint o;

				o.localPos = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				return o;
			}

			/// TESSELLATION //////////////////////////////////////////////////////////

#if !defined(TESSELLATION_INCLUDED)
#define TESSELLATION_INCLUDED


[partitioning("integer")]
[UNITY_domain("tri")]
[UNITY_outputcontrolpoints(3)]
[UNITY_outputtopology("triangle_cw")]
[UNITY_patchconstantfunc("MyPatchConstantFunction")]
TessellationControlPoint MyHullProgram(InputPatch<TessellationControlPoint, 3> patch, uint id: SV_OutputControlPointID)
{
	return patch[id];
}

struct TessellationFactors
{
	float edge[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};

TessellationFactors MyPatchConstantFunction(InputPatch<TessellationControlPoint, 3> patch)
{
	TessellationFactors f;

	f.edge[0] = 4;
	f.edge[1] = 4;
	f.edge[2] = 4;
	f.inside = 4;

	return f;
}

[UNITY_domain("tri")]
TessellationControlPoint MyDomainProgram
(
	TessellationFactors factors,
	OutputPatch<TessellationControlPoint, 3> patch,
	float3 barycentricCoordinates : SV_DomainLocation
)
{
	TessellationControlPoint data;

#define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) data.fieldName = \
				patch[0].fieldName * barycentricCoordinates.x + \
				patch[1].fieldName * barycentricCoordinates.y + \
				patch[2].fieldName * barycentricCoordinates.z;

	MY_DOMAIN_PROGRAM_INTERPOLATE(vertex);
	MY_DOMAIN_PROGRAM_INTERPOLATE(localPos);
	MY_DOMAIN_PROGRAM_INTERPOLATE(worldPos);

	return vert(data);
}

TessellationControlPoint MyTessellationVertexProgram(TessellationControlPoint v)
{
	return v;
}

#endif
/// TESSELLATION END //////////////////////////////////////////////////////////
			

			

			

			[maxvertexcount(3)]
			void geom(triangle v2g i[3], inout TriangleStream<g2f> triangleStream)
			{
				fixed3 extraDist = fixed3(0,0,0);

				g2f o;

				o.dist = fixed3(1, 0, 0) + extraDist;
				o.vertex = i[0].vertex;
				triangleStream.Append(o);

				o.dist = fixed3(0, 1, 0) + extraDist;
				o.vertex = i[1].vertex;
				triangleStream.Append(o);

				o.dist = fixed3(0, 0, 1) + extraDist;
				o.vertex = i[2].vertex;
				triangleStream.Append(o);
			}

			fixed4 frag(g2f i) : SV_Target
			{
				fixed4 col;

				fixed minDistToEdge = min(i.dist[0], min(i.dist[1], i.dist[2]));

				if (minDistToEdge < _Thickness)
					col = _Color;
				else
					col = _FillColor;

				return col;
			}

				ENDCG
		}
	}
}

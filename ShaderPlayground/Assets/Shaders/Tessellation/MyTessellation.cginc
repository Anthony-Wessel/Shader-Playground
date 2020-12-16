#if !defined(TESSELLATION_INCLUDED)
#define TESSELLATION_INCLUDED

struct TessellationControlPoint
{
	float4 vertex : INTERNALTESSPOS;
	float4 localPos : TEXCOORD1;
	float3 worldPos : TEXCOORD2;
};

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

	f.edge[0] = 2;
	f.edge[1] = 2;
	f.edge[2] = 2;
	f.inside = 2;

	return f;
}

[UNITY_domain("tri")]
v2g MyDomainProgram
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

	return MyVertexProgram(data);
}

TessellationControlPoint MyTessellationVertexProgram(TessellationControlPoint v)
{
	return v;
}

#endif
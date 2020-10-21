

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

v2g vert(float4 vertex : POSITION)
{
	v2g o;

	o.localPos = vertex;
	o.vertex = UnityObjectToClipPos(vertex);
	o.worldPos = mul(unity_ObjectToWorld, vertex);

	return o;
}

[maxvertexcount(3)]
void geom(triangle v2g i[3], inout TriangleStream<g2f> triangleStream)
{
	fixed3 extraDist = fixed3(0,0,0);

#ifdef HIDE_DIAGONALS
	fixed edge0 = length(i[1].worldPos - i[2].worldPos);
	fixed edge1 = length(i[0].worldPos - i[2].worldPos);
	fixed edge2 = length(i[0].worldPos - i[1].worldPos);
	
	extraDist = lerp(fixed3(1, 0, 0), fixed3(0, 1, 0), step(0, edge1 - edge0));
	extraDist = lerp(extraDist, fixed3(0, 0, 1), step(0, edge2 - max(edge0, edge1)));
#endif
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

// ignore long side of triangle?

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
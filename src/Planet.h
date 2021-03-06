// Copyright © 2008-2012 Pioneer Developers. See AUTHORS.txt for details
// Licensed under the terms of the GPL v3. See licenses/GPL-3.txt

#ifndef _PLANET_H
#define _PLANET_H

#include "TerrainBody.h"
#include "graphics/VertexArray.h"
#include "SmartPtr.h"

namespace Graphics {
	class Renderer;
	class Texture;
	class Material;
}

class Planet: public TerrainBody {
public:
	OBJDEF(Planet, TerrainBody, PLANET);
	Planet(SystemBody*);
	Planet();
	virtual ~Planet();

	virtual double GetClipRadius() const { return m_clipRadius; }
	virtual void SubRender(Graphics::Renderer *r, const Camera *camera, const vector3d &camPos);

	void GetAtmosphericState(double dist, double *outPressure, double *outDensity) const;

#if WITH_OBJECTVIEWER
	friend class ObjectViewerView;
#endif

protected:
	virtual void Load(Serializer::Reader &rd, Space *space);

private:
	void GenerateRings(Graphics::Renderer *renderer);
	void DrawGasGiantRings(Graphics::Renderer *r, const Camera *camera);
	void DrawAtmosphere(Graphics::Renderer *r, const vector3d &camPos);

	double m_clipRadius;
	RefCountedPtr<Graphics::Texture> m_ringTexture;
	Graphics::VertexArray m_ringVertices;
	ScopedPtr<Graphics::Material> m_ringMaterial;

	// Legacy renderer visuals
	ScopedPtr<Graphics::VertexArray> m_atmosphereVertices;
	ScopedPtr<Graphics::Material> m_atmosphereMaterial;
};

#endif /* _PLANET_H */

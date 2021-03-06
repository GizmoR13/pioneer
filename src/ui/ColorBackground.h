// Copyright © 2008-2012 Pioneer Developers. See AUTHORS.txt for details
// Licensed under the terms of the GPL v3. See licenses/GPL-3.txt

#ifndef UI_COLORBACKGROUND_H
#define UI_COLORBACKGROUND_H

#include "Single.h"
#include "Color.h"
#include "graphics/Material.h"

namespace UI {

class ColorBackground : public Single {
public:
	virtual void Draw();

	void SetColor(const Color &color) { m_material->diffuse = color; }

protected:
	friend class Context;
	ColorBackground(Context *context, const Color &color);

private:
	ScopedPtr<Graphics::Material> m_material;
};

}

#endif

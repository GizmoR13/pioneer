// Copyright © 2008-2012 Pioneer Developers. See AUTHORS.txt for details
// Licensed under the terms of the GPL v3. See licenses/GPL-3.txt

#include "WorldViewCamera.h"
#include "Ship.h"
#include "Pi.h"
#include "Game.h"
#include "AnimationCurves.h"

WorldViewCamera::WorldViewCamera(const Ship *s, const vector2f &size, float fovY, float near, float far) :
	Camera(s, size.x, size.y, fovY, near, far)
{

}

InternalCamera::InternalCamera(const Ship *s, const vector2f &size, float fovY, float near, float far) :
	WorldViewCamera(s, size, fovY, near, far)
{
	s->onFlavourChanged.connect(sigc::bind(sigc::mem_fun(this, &InternalCamera::OnShipFlavourChanged), s));
	OnShipFlavourChanged(s);
	SetBodyVisible(false);
	SetMode(MODE_FRONT);
}

void InternalCamera::OnShipFlavourChanged(const Ship *s)
{
	SetPosition(s->GetShipType().cameraOffset);
}

void InternalCamera::SetMode(Mode m)
{
	m_mode = m;
	switch (m_mode) {
		case MODE_FRONT:
			m_name = Lang::CAMERA_FRONT_VIEW;
			SetOrientation(matrix4x4d::RotateYMatrix(M_PI*2));
			break;
		case MODE_REAR:
			m_name = Lang::CAMERA_REAR_VIEW;
			SetOrientation(matrix4x4d::RotateYMatrix(M_PI));
			break;
		case MODE_LEFT:
			m_name = Lang::CAMERA_LEFT_VIEW;
			SetOrientation(matrix4x4d::RotateYMatrix((M_PI/2)*3));
			break;
		case MODE_RIGHT:
			m_name = Lang::CAMERA_RIGHT_VIEW;
			SetOrientation(matrix4x4d::RotateYMatrix(M_PI/2));
			break;
		case MODE_TOP:
			m_name = Lang::CAMERA_TOP_VIEW;
			SetOrientation(matrix4x4d::RotateXMatrix((M_PI/2)*3));
			break;
		case MODE_BOTTOM:
			m_name = Lang::CAMERA_BOTTOM_VIEW;
			SetOrientation(matrix4x4d::RotateXMatrix(M_PI/2));
			break;
	}
}

void InternalCamera::Save(Serializer::Writer &wr)
{
	wr.Int32(m_mode);
}

void InternalCamera::Load(Serializer::Reader &rd)
{
	SetMode(static_cast<Mode>(rd.Int32()));
}


ExternalCamera::ExternalCamera(const Ship *s, const vector2f &size, float fovY, float near, float far) :
	MoveableCamera(s, size, fovY, near, far),
	m_dist(200), m_distTo(m_dist),
	m_rotX(0),
	m_rotY(0),
	m_orient(matrix4x4d::Identity())
{
}

void ExternalCamera::RotateUp(float frameTime)
{
	m_rotX -= 45*frameTime;
}

void ExternalCamera::RotateDown(float frameTime)
{
	m_rotX += 45*frameTime;
}

void ExternalCamera::RotateLeft(float frameTime)
{
	m_rotY -= 45*frameTime;
}

void ExternalCamera::RotateRight(float frameTime)
{
	m_rotY += 45*frameTime;
}

void ExternalCamera::ZoomIn(float frameTime)
{
	ZoomOut(-frameTime);
}

void ExternalCamera::ZoomOut(float frameTime)
{
	m_dist += 400*frameTime;
	m_dist = std::max(GetBody()->GetBoundingRadius(), m_dist);
	m_distTo = m_dist;
}

void ExternalCamera::ZoomEvent(float amount)
{
	m_distTo += 400*amount;
	m_distTo = std::max(GetBody()->GetBoundingRadius(), m_distTo);
}

void ExternalCamera::ZoomEventUpdate(float frameTime)
{
	AnimationCurves::Approach(m_dist, m_distTo, frameTime);
	m_dist = std::max(GetBody()->GetBoundingRadius(), m_dist);
}

void ExternalCamera::Reset()
{
	m_dist = 200;
	m_distTo = m_dist;
}

void ExternalCamera::UpdateTransform()
{
	// when landed don't let external view look from below
	// XXX shouldn't be limited to player
	const Body *b = GetBody();
	if (b->IsType(Object::PLAYER)) {
		if (static_cast<const Ship*>(b)->GetFlightState() == Ship::LANDED ||
			static_cast<const Ship*>(b)->GetFlightState() == Ship::DOCKED) {
			m_rotX = Clamp(m_rotX, -170.0, -10.0);
		}
	}
	vector3d p = vector3d(0, 0, m_dist);
	p = matrix4x4d::RotateXMatrix(-DEG2RAD(m_rotX)) * p;
	p = matrix4x4d::RotateYMatrix(-DEG2RAD(m_rotY)) * p;
	m_orient = matrix4x4d::RotateYMatrix(-DEG2RAD(m_rotY)) *
		matrix4x4d::RotateXMatrix(-DEG2RAD(m_rotX));
	SetPosition(p);
	SetOrientation(m_orient);
}

void ExternalCamera::Save(Serializer::Writer &wr)
{
	wr.Float(float(m_rotX));
	wr.Float(float(m_rotY));
	wr.Float(float(m_dist));
}

void ExternalCamera::Load(Serializer::Reader &rd)
{
	m_rotX = rd.Float();
	m_rotY = rd.Float();
	m_dist = rd.Float();
	m_distTo = m_dist;
}

SiderealCamera::SiderealCamera(const Ship *s, const vector2f &size, float fovY, float near, float far) :
	MoveableCamera(s, size, fovY, near, far),
	m_dist(200), m_distTo(m_dist),
	m_orient(matrix4x4d::Identity())
{
	m_prevShipOrient = s->GetTransformRelTo(Pi::game->GetSpace()->GetRootFrame());
}

void SiderealCamera::RotateUp(float frameTime)
{
	const vector3d rotAxis = m_orient * vector3d(1,0,0);
	m_orient = matrix4x4d::RotateMatrix(-M_PI/4 * frameTime, rotAxis.x, rotAxis.y, rotAxis.z)
		* m_orient;
}

void SiderealCamera::RotateDown(float frameTime)
{
	const vector3d rotAxis = m_orient * vector3d(1,0,0);
	m_orient = matrix4x4d::RotateMatrix(M_PI/4 * frameTime, rotAxis.x, rotAxis.y, rotAxis.z)
		* m_orient;
}

void SiderealCamera::RotateLeft(float frameTime)
{
	const vector3d rotAxis = m_orient * vector3d(0,1,0);
	m_orient = matrix4x4d::RotateMatrix(-M_PI/4 * frameTime, rotAxis.x, rotAxis.y, rotAxis.z)
		* m_orient;
}

void SiderealCamera::RotateRight(float frameTime)
{
	const vector3d rotAxis = m_orient * vector3d(0,1,0);
	m_orient = matrix4x4d::RotateMatrix(M_PI/4 * frameTime, rotAxis.x, rotAxis.y, rotAxis.z)
		* m_orient;
}

void SiderealCamera::ZoomIn(float frameTime)
{
	ZoomOut(-frameTime);
}

void SiderealCamera::ZoomOut(float frameTime)
{
	m_dist += 400*frameTime;
	m_dist = std::max(GetBody()->GetBoundingRadius(), m_dist);
	m_distTo = m_dist;
}

void SiderealCamera::ZoomEvent(float amount)
{
	m_distTo += 400*amount;
	m_distTo = std::max(GetBody()->GetBoundingRadius(), m_distTo);
}

void SiderealCamera::ZoomEventUpdate(float frameTime)
{
	AnimationCurves::Approach(m_dist, m_distTo, frameTime, 4.0, 50./std::max(m_distTo, 1e-7));		// std::max() here just avoid dividing by 0.
	m_dist = std::max(GetBody()->GetBoundingRadius(), m_dist);
}

void SiderealCamera::RollLeft(float frameTime)
{
	const vector3d rotAxis = m_orient * vector3d(0,0,1);
	m_orient = matrix4x4d::RotateMatrix(M_PI/4 * frameTime, rotAxis.x, rotAxis.y, rotAxis.z)
		* m_orient;
}

void SiderealCamera::RollRight(float frameTime)
{
	const vector3d rotAxis = m_orient * vector3d(0,0,1);
	m_orient = matrix4x4d::RotateMatrix(-M_PI/4 * frameTime, rotAxis.x, rotAxis.y, rotAxis.z)
		* m_orient;
}

void SiderealCamera::Reset()
{
	m_dist = 200;
	m_distTo = m_dist;
}

void SiderealCamera::UpdateTransform()
{
	const matrix4x4d curShipOrient = static_cast<const Ship*>(GetBody())->GetInterpolatedTransformRelTo(Pi::game->GetSpace()->GetRootFrame());

	const matrix4x4d invAngDisp = curShipOrient.InverseOf() * m_prevShipOrient;
	m_orient = invAngDisp * m_orient;

	m_orient.Renormalize();
	m_orient.ClearToRotOnly();

	m_prevShipOrient = curShipOrient;

	const vector3d p = m_orient * vector3d(0, 0, m_dist);
	SetPosition(p);
	SetOrientation(m_orient);
}

void SiderealCamera::Save(Serializer::Writer &wr)
{
	for (int i = 0; i < 16; i++) wr.Float(float(m_orient[i]));
	wr.Float(float(m_dist));
}

void SiderealCamera::Load(Serializer::Reader &rd)
{
	for (int i = 0; i < 16; i++) m_orient[i] = rd.Float();
	m_dist = rd.Float();
	m_distTo = m_distTo;
	m_prevShipOrient = static_cast<const Ship*>(GetBody())->GetTransformRelTo(Pi::game->GetSpace()->GetRootFrame());
}

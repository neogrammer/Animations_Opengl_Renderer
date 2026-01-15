/* a simple, line based arrow */
#pragma once
#include <vector>
#include <glm/glm.hpp>

#include "../opengl/OGLRenderData.h"

class ArrowModel {
  public:
    OGLMesh getVertexData();

  private:
    void init();
    OGLMesh mVertexData;
};

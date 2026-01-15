/* Dear ImGui*/
#pragma once

#include "../opengl/OGLRenderData.h"

class UserInterface {
  public:
    void init(OGLRenderData &renderData);
    void createFrame(OGLRenderData &renderData);
    void render();
    void cleanup();

  private:
    float mFramesPerSecond = 0.0f;
    /* averaging speed */
    float mAveragingAlpha = 0.96f;
};

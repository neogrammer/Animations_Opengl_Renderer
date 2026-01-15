#include "GltfAnimationClip.h"
#include "../tools/Logger.h"

GltfAnimationClip::GltfAnimationClip(std::string name) : mClipName(name) {}

void GltfAnimationClip::addChannel(std::shared_ptr<tinygltf::Model> model, tinygltf::Animation anim, tinygltf::AnimationChannel channel) {
	std::shared_ptr<GltfAnimationChannel> chan = std::make_shared<GltfAnimationChannel>();
	chan->loadChannelData(model, anim, channel);
	mAnimationChannels.push_back(chan);
}

void GltfAnimationClip::setAnimationFrame(std::vector<std::shared_ptr<GltfNode>> nodes, float time)
{
	Logger::log(1, "%s made it into the function\n", __FUNCTION__);
	for (auto& channel : mAnimationChannels)
	{
		Logger::log(1, "%s foreach in\n", __FUNCTION__);

		int targetNode = channel->getTargetNode();

		switch (channel->getTargetPath())
		{
		case ETargetPath::ROTATION:
			Logger::log(1, "%s ROTATION %d %d\n", __FUNCTION__, targetNode,nodes.size());
			nodes.at(targetNode)->setRotation(channel->getRotation(time));
			Logger::log(1, "%s ROTATION successful\n", __FUNCTION__);
			break;
		case ETargetPath::TRANSLATION:
			Logger::log(1, "%s Translation\n", __FUNCTION__);

			nodes.at(targetNode)->setTranslation(channel->getTranslation(time));
			break;
		case ETargetPath::SCALE:
			Logger::log(1, "%s SCALE\n", __FUNCTION__);
			nodes.at(targetNode)->setScale(channel->getScaling(time));
			break;
		default:
			Logger::log(1, "%s improper ETargetPAth\n", __FUNCTION__);
			break;

		}
		Logger::log(1, "%s iterated foreach\n", __FUNCTION__);

	}
	Logger::log(1, "%s made it out of foreach\n", __FUNCTION__);


	for (auto& node : nodes)
	{
		if (node)
		{
			node->calculateLocalTRSMatrix();
		}
	}

}

float GltfAnimationClip::getClipEndTime()
{
	Logger::log(1, "%s Attempting to get the channel maxtime\n", __FUNCTION__);
	return mAnimationChannels.at(0)->getMaxTime();
}

std::string GltfAnimationClip::getClipName()
{
	return mClipName;
}

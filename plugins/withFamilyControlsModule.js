const { withXcodeProject } = require('@expo/config-plugins');
const {
  addBuildSourceFileToGroup,
  ensureGroupRecursively,
} = require('@expo/config-plugins/build/ios/utils/Xcodeproj');

const IOS_TARGET_NAME = 'HexitFresh';
const SOURCE_FILES = ['FamilyControlsModule.swift', 'FamilyControlsModule.m'];

function ensureSourceFileLinked(project, fileName) {
  const target = project.pbxTargetByName(IOS_TARGET_NAME);
  if (!target) {
    throw new Error(`Unable to find iOS target "${IOS_TARGET_NAME}" in the Xcode project.`);
  }

  ensureGroupRecursively(project, IOS_TARGET_NAME);

  addBuildSourceFileToGroup({
    filepath: fileName,
    groupName: IOS_TARGET_NAME,
    project,
    targetUuid: target.uuid,
  });
}

module.exports = (config) =>
  withXcodeProject(config, (modConfig) => {
    const project = modConfig.modResults;

    SOURCE_FILES.forEach((fileName) => ensureSourceFileLinked(project, fileName));

    return modConfig;
  });

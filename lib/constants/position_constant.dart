import 'package:flutter/material.dart';

enum PositionConstant {
  bottomLeft,
  bottomRight,
}

Map<int, Alignment> positionAlignmentConstant = {
  PositionConstant.bottomLeft.index: Alignment.bottomLeft,
  PositionConstant.bottomRight.index: Alignment.bottomRight,
};

Map<PositionConstant, String> positionLabelConstant = {
  PositionConstant.bottomLeft: '左下角',
  PositionConstant.bottomRight: '右下角',
};

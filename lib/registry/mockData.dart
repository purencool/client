/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:animated_tree_view/animated_tree_view.dart';

class NotesMockData {
  static TreeNode<String> get initialFileTree => TreeNode.root()
    ..addAll([
      TreeNode(key: "docs", data: "Documents")..addAll([
        TreeNode(key: "file1", data: "Work_Plan.md"),
        TreeNode(key: "file2", data: "Project_X.md"),
      ]),
      TreeNode(key: "file3", data: "Personal_Goals.txt"),
    ]);
}


final notes = {
  'notes_tree': () => NotesMockData.initialFileTree,
};
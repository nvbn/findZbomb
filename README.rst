Welcome to findZbomb!
=====================

In this game you need to write python source code for robot and remove bomb!
For this action you need to create new robot class based on BaseRobot. They has two events:

- *on_start* -- when game start you need to do first move;
- *on_move(self, status)* -- when move permitted, *status* display last move status;

And robot have three built-in methods:

- *go(self, destination)* -- go to the block;
- *watch(self, destination)* -- get block;
- *remove_bomb(self, destination)* -- remove bomb block;

Available destinations: self.LEFT, self.TOP_LEFT, self.TOP, self.TOP_RIGHT, self.RIGHT, self.BOTTOM_RIGHT, self.BOTTOM and self.BOTTOM_LEFT.

You can check block type calling *type(block)*, available types: Bomb, Block and Space.
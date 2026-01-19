# HARMONI GRAPH

This is a musical instrument/toy. A new way to create music.

### how to open

To execute this software you need [LÖVE](https://love2d.org/) version 11.5

Just execute the file HarmoniGraph.love

### How to use it

- Left click on the screen to create an empty **node**
- Right click and hold from one **node** to another to create an **arrow**
- Click on a color from the Palette on the right, the next **node** will be colored as such. Each color represents a note and the Palette is the circle of fifths
- Use the mouse wheel to change the octave in the bar bellow the Palette
- A **node** is a **root** if there are no arrows pointing to it
- You need at least one **root node** in order to play the music
- Now you can press F and listen to your own musical graph
- If a node has multiple arrows going out, it will play in order once you loop back to that node.

### Next steps

- Develop the ability to delete nodes and arrows
- Develop the ability to change the note of a given node
- Develop the ability to select multiple nodes
- Add a Sound picker for percussive sounds
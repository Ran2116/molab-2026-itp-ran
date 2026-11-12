[Title Placeholder]

A camera app that collects letters in daily life and turns them into collage text

I would like to create an app that let people build their own alphabet/ letter collection from the text around them. When people point the camera at a street sign, a receipt, a snack package or a storefront and take a photo, the app would find the text, cut it into individual letters and save each one to user's personal letter library. Over time user would end up with a collection of A’s, B’s and C’s in many typefaces, colors and textures.

This app would also work as a custom typing tool. Users can type any word or sentence and the app spells it out in a ransom-note style collage, using letters users have collected. Users can swap any letter for another version from the library and move, scale and rotate each piece. They can export the collage as a transparent image or place it on top of a photo just like the way of adding text to an Instagram story.

Working Timeline:

Week 1: Capture, detect and cut. Get a photo from the camera or library, run Vision text recognition, and draw the bounding boxes over the image. Test how reliable character-level boxes are on different kinds of signage, then crop each character into its own labeled image.

Week 2: Library and type-to-collage. Save letters with SwiftData, build the A–Z library view, turn typed text into a collage of library letters and add tap-to-swap.

Week 3: Edit, overlay and export. Add drag/scale/rotate gestures, background photo overlay, export to Photos (including transparent PNG), and tools for deleting bad crops.

Week 4: Testing and presentation. Collect letters around the city, fix bugs, polish the visuals, document the process on the wiki, and prepare the final presentation.

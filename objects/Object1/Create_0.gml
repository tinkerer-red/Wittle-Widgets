// 🌟 Root GUI
root = new WWCore()
    .set_offset(0, 0)
    .set_size(0, 0, 1280, 720)
    .set_enabled(true);

// 🌟 Slider Test Panel
sliderPanel = new WWCore()
    .set_offset(100, 50)
    .set_size(600, 620)
    .set_enabled(true);

// 📌 Title
title = new WWText()
    .set_offset(250, 10)
    .set_text("Slider Test Suite")
    .set_text_alignment(fa_center, fa_middle)
    .set_text_color(c_white);
sliderPanel.add(title);

// 📌 Basic Horizontal Slider
slider1Label = new WWText()
    .set_offset(50, 50)
    .set_text("Basic Horizontal Slider:")
    .set_text_color(c_white);
slider1 = new WWSliderHorz()
    .set_offset(50, 70)
    .set_size(500, 20)
    .set_clamp_values(0, 100)
    .set_value(50);
sliderPanel.add(slider1Label, slider1);

// 📌 Basic Vertical Slider
slider2Label = new WWText()
    .set_offset(570, 50)
    .set_text("Basic Vertical Slider:")
    .set_text_color(c_white);
slider2 = new WWSliderVert()
    .set_offset(570, 70)
    .set_size(20, 250)
    .set_clamp_values(0, 100)
    .set_value(25);
sliderPanel.add(slider2Label, slider2);

// 📌 Rounded Integer Slider
slider3Label = new WWText()
    .set_offset(50, 100)
    .set_text("Rounded (Integer) Slider:")
    .set_text_color(c_white);
slider3 = new WWSliderHorz()
    .set_offset(50, 120)
    .set_size(500, 20)
    .set_clamp_values(0, 10)
    .set_value(5)
    .set_rounding(true);
sliderPanel.add(slider3Label, slider3);

// 📌 Read-Only Progress Bar
progressLabel = new WWText()
    .set_offset(50, 150)
    .set_text("Read-Only Progress Bar:")
    .set_text_color(c_white);
progressBar = new WWSliderHorz()
    .set_offset(50, 170)
    .set_size(500, 20)
    .set_clamp_values(0, 100)
    .set_value(75)
    .set_input_enabled(false);
sliderPanel.add(progressLabel, progressBar);

// 📌 Inverted Sliders
invertedHorzLabel = new WWText()
    .set_offset(50, 200)
    .set_text("Inverted Horizontal Slider:")
    .set_text_color(c_white);
invertedHorz = new WWSliderHorz()
    .set_offset(50, 220)
    .set_size(500, 20)
    .set_clamp_values(0, 100)
    .set_value(60)
    .set_inverted(true);
sliderPanel.add(invertedHorzLabel, invertedHorz);

invertedVertLabel = new WWText()
    .set_offset(610, 50)
    .set_text("Inverted Vertical Slider:")
    .set_text_color(c_white);
invertedVert = new WWSliderVert()
    .set_offset(610, 70)
    .set_size(20, 250)
    .set_clamp_values(0, 100)
    .set_value(40)
    .set_inverted(true);
sliderPanel.add(invertedVertLabel, invertedVert);

// 📌 Large Range Slider
largeRangeLabel = new WWText()
    .set_offset(50, 250)
    .set_text("Large Range Slider (0-500):")
    .set_text_color(c_white);
largeRange = new WWSliderHorz()
    .set_offset(50, 270)
    .set_size(500, 20)
    .set_clamp_values(0, 500)
    .set_value(250);
sliderPanel.add(largeRangeLabel, largeRange);

// 📌 Horizontal Slider with Thumb
sliderHorzThumbLabel = new WWText()
    .set_offset(50, 300)
    .set_text("Horizontal Slider with Thumb:")
    .set_text_color(c_white);
sliderHorzThumb = new WWSliderHorzThumb()
    .set_offset(50, 320)
    .set_size(500, 20)
    .set_clamp_values(0, 100)
    .set_value(60);
sliderPanel.add(sliderHorzThumbLabel, sliderHorzThumb);

// 📌 Vertical Slider with Thumb
sliderVertThumbLabel = new WWText()
    .set_offset(610, 320)
    .set_text("Vertical Slider with Thumb:")
    .set_text_color(c_white);
sliderVertThumb = new WWSliderVertThumb()
    .set_offset(610, 340)
    .set_size(20, 250)
    .set_clamp_values(0, 100)
    .set_value(40)
    .set_inverted(false);
sliderPanel.add(sliderVertThumbLabel, sliderVertThumb);

// 📌 Move Sliders Button
moveButton = new WWButtonText()
    .set_offset(50, 600)
    .set_size(120, 40)
    .set_text("Move Sliders")
    .set_callback(function() {
        slider1.set_offset(50, 360);
        slider2.set_offset(570, 180);
        slider3.set_offset(50, 400);
        progressBar.set_offset(50, 440);
        invertedHorz.set_offset(50, 480);
        invertedVert.set_offset(610, 180);
        largeRange.set_offset(50, 520);
        sliderHorzThumb.set_offset(50, 560);
        sliderVertThumb.set_offset(610, 420);
    });
sliderPanel.add(moveButton);

// 📌 Reset Values Button
resetButton = new WWButtonText()
    .set_offset(200, 600)
    .set_size(120, 40)
    .set_text("Reset Values")
    .set_callback(function() {
        slider1.set_lerp_target(50);
        slider2.set_lerp_target(25);
        slider3.set_lerp_target(5);
        progressBar.set_lerp_target(75);
        invertedHorz.set_lerp_target(60);
        invertedVert.set_lerp_target(40);
        largeRange.set_lerp_target(250);
        sliderHorzThumb.set_lerp_target(60);
        sliderVertThumb.set_lerp_target(40);
    });
sliderPanel.add(resetButton);

// 📌 Random Values Button
randomButton = new WWButtonText()
    .set_offset(350, 600)
    .set_size(120, 40)
    .set_text("Random Values")
    .set_callback(function() {
        slider1.set_lerp_target(irandom(100));
        slider2.set_lerp_target(irandom(100));
        slider3.set_lerp_target(irandom(10));
        progressBar.set_lerp_target(irandom(100));
        invertedHorz.set_lerp_target(irandom(100));
        invertedVert.set_lerp_target(irandom(100));
        largeRange.set_lerp_target(irandom(500));
        sliderHorzThumb.set_lerp_target(irandom(100));
        sliderVertThumb.set_lerp_target(irandom(100));
    });
sliderPanel.add(randomButton);

// 📌 Toggle Inversion Button
toggleInversionButton = new WWButtonText()
    .set_offset(500, 600)
    .set_size(120, 40)
    .set_text("Toggle Inversion")
    .set_callback(function() {
        slider1.set_inverted(!slider1.is_inverted);
        slider2.set_inverted(!slider2.is_inverted);
        slider3.set_inverted(!slider3.is_inverted);
        invertedHorz.set_inverted(!invertedHorz.is_inverted);
        invertedVert.set_inverted(!invertedVert.is_inverted);
        progressBar.set_inverted(!progressBar.is_inverted);
        sliderHorzThumb.set_inverted(!sliderHorzThumb.is_inverted);
        sliderVertThumb.set_inverted(!sliderVertThumb.is_inverted);
    });
sliderPanel.add(toggleInversionButton);

// 🌟 Add everything to root
root.add(sliderPanel);

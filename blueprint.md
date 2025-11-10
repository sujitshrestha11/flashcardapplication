# Blueprint: Korean Word Speaking Trainer

## Overview

This document outlines the plan for creating a Flutter application designed to help users practice their Korean pronunciation. The app will allow users to input a list of Korean words with their English translations, and then listen to the words spoken sequentially or in a shuffled order. The user can control the playback, including repetitions, speed, and whether to include the English translation. The app will feature a modern, dark-themed UI inspired by popular streaming services.

## Features

### Core Functionality

- **Vocabulary Input**: A text area for users to paste or type their vocabulary list. The format will be `Korean word ; English translation` on each line.
- **Sequential Playback**: The app will read through the vocabulary list from top to bottom.
- **Shuffle Playback**: The app will shuffle the list and play the words in a random order.
- **Repetitions**: Users can set the number of times each word is repeated before moving to the next.
- **Shuffle Reps**: In shuffle mode, users can define how many times each word is added to the shuffled list.
- **Playback Speed**: A slider to control the speech rate of the text-to-speech engine.
- **Toggle English**: A switch to enable or disable the speaking of the English translation after the Korean word.
- **Playback Controls**: Buttons to start, shuffle, and stop playback.

### UI/UX

- **Modern Design**: A sleek, dark-themed interface inspired by the provided image, using a deep teal accent color.
- **Typography**: Clean, sans-serif fonts (Poppins) with a clear hierarchy.
- **Layout**: A `CustomScrollView` with a `SliverAppBar` for a modern, flexible layout. The content will be displayed in styled cards with rounded corners and soft shadows.
- **Background**: A subtle gradient background to add depth and visual appeal.
- **Dark Mode**: A fully integrated dark theme as the primary interface, with a theme toggle for a light mode option.
- **Theme Persistence**: The user's theme preference is saved across app sessions.
- **Stateful Controls**: UI elements like text fields and buttons are enabled/disabled based on the playback state.
- **Visual Feedback**: The currently playing word in the queue is highlighted, and the list auto-scrolls to it.
- **Status Display**: A clear status message informs the user of the playback progress.

## Technical Implementation

- **State Management**: `provider` for managing the application state, including the theme and the trainer's state.
- **Text-to-Speech**: The `flutter_tts` package will be used for text-to-speech functionality.
- **Persistence**: `shared_preferences` to save the user's theme preference.
- **UI Toolkit**: Flutter with Material Design 3 components.
- **Fonts**: The `google_fonts` package to use the Poppins font.
- **Theming**: A custom `ThemeData` will be created to match the design, with a `ColorScheme` based on a dark teal seed color.

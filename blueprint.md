
# Project Blueprint

## Overview

This document outlines the structure and features of the Esha AI friend application.

## Implemented Features

*   **Initial Setup:** Basic Flutter project structure.
*   **Core Screens:** Basic versions of Login, AI, and Settings screens.
*   **Navigation:** Routing between screens using `go_router`.

## Current Goal

Refine the UI to exactly match the provided HTML mockup for the Login, AI, and Settings screens, using the "Midnight Blue" color palette. Remove all platforms other than Android and iOS.

## Plan

1.  **Cleanup Project:**
    *   Remove the `web` directory to support only Android and iOS.
    *   Delete the default `widget_test.dart` file.
2.  **Refine Login Screen:**
    *   Implement the circular app logo.
    *   Match the text styles, input fields, and button design from the mockup.
3.  **Refine AI Screen:**
    *   Build the header with the AI's avatar and status.
    *   Create the voice interaction animation, including pulsing rings and audio waves.
    *   Add the control buttons for mute and record.
4.  **Refine Settings Screen:**
    *   Implement the user profile section.
    *   Create the categorized lists for settings items, including toggles and navigation arrows.
5.  **Update Theme:** Adjust the global `ThemeData` in `main.dart` to ensure colors and styles are consistent with the "Midnight Blue" palette.

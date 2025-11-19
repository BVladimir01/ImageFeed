# ImageFeed App

## Overview
An app for viewing infinite feed of iamges from Unsplash

## Features
- Scroll through feed of images
- Add images to favourites
- Visit profile

## Tech Stack
- **Language:** Swift
- **Architecture:** MVP + MVC
- **Frameworks:** UIKit, Kingfisher, ProgressHUD, SwiftKeyChainWrapper
- **Tools:** SPM, OAuth

## Installation
```bash
git clone https://github.com/BVladimir01/ImageFeed
cd ImageFeed
open ImageFeed.xcodeproj
```

### Requirements
- Swift 5.x
- iOS 13+
- Xcode 16+

## Preview

|Authorization|Feed|Image operation|Logout|
|:-----------:|:--:|:-------------:|:----:|
|<img src="PreviewGIFs/auth.gif" width="150"/>|<img src="PreviewGIFs/feed.gif" width="150"/>|<img src="PreviewGIFs/image.gif" width="150"/>|<img src="PreviewGIFs/logout.gif" width="150"/>|

##  Project Structure

**ImageFeed/** \
├ **App/** *Top level app files* \
├ **Authorization/** *Cart tab files* \
├ **ImagesList/** *Catalog tab files* \
├ **Profile/** *Core elements: UI elemtns, models, and services* \
├ **UIComponents/** *Profile tab files* \
├ **Networking/** *Statistics tab files* \
└ **Resources/** *Images, infoplist* \
**ImageFeedTests/** *Unit tests* \
**ImageFeedUITests/** *UI tests* \

## Future plan
- [ ] Make full MVP (delete legacy MVC)
- [ ] Refactor Network layer
- [ ] Localize
- [ ] Add light/dark theme support
- [ ] Remove Storyboards
- [ ] Increase tests coverage
- [ ] Add documentation

## Acknowledgements
Big thanks to Yandex Practicum reviewers.


[auth_gif]: PreviewGIFs/auth.gif
[feed_gif]: PreviewGIFs/feed.gif 
[image_gif]: PreviewGIFs/image.gif
[logout_gif]: PreviewGIFs/logout.gif

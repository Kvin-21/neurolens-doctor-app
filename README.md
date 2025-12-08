# NeuroLens Doctor Portal

The Windows desktop application for doctors to view and track cognitive assessment data from the NeuroLens backend ML system.

## Features

- Patient management with password-protected access
- Display of 75 cognitive features (42 acoustic, 15 linguistic, 18 LLM scores)
- MMSE score tracking with interactive charts
- Session history and diagnosis probabilities

## Requirements

- Flutter SDK 3.0+
- Windows 10/11
- Visual Studio 2019/2022 with Desktop development with C++
- Windows 11 SDK

## Quick Start

```bash
git clone https://github.com/Kvin-21/Neuro_Doctor.git
cd Neuro_Doctor
flutter pub get
flutter run -d windows
```

## Build

```bash
flutter build windows --release
```

The executable will be in `build\windows\x64\runner\Release\`

## Usage

1. Click **Add Patient**, enter a valid ID (P001, P002, P003), password `1234`, and a display name
2. View the **Dashboard** for MMSE trends and summaries
3. Switch to **Detailed Features** for all 75 features extracted by AI model

## Project Structure

```
lib/
├── models/      Data models (features, sessions, patients)
├── providers/   State management
├── screens/     UI screens
├── services/    Storage, security, mock data
├── utils/       Constants, theme, validators
└── widgets/     Reusable UI components
```

### Data Models
- **AcousticFeatures**: 42 speech signal features
- **LinguisticFeatures**: 15 language analysis features
- **LLMClinicalScores**: 18 AI-assessed cognitive markers
- **Session**: Complete assessment record with MMSE score

## Security

- Password-protected patient addition
- Rate limiting on failed attempts
- Local storage only (no cloud sync)
- ID-to-name mapping stored on device


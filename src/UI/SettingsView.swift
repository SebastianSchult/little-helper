import SwiftUI
import KeyboardShortcuts
import ServiceManagement

struct SettingsView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var modelManager = ModelManager.shared
    @State private var ollamaModels: [String] = [OllamaEnhancer.defaultModel]

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { SMAppService.mainApp.status == .enabled },
            set: { enabled in
                if enabled { try? SMAppService.mainApp.register() }
                else        { try? SMAppService.mainApp.unregister() }
            }
        )
    }

    var body: some View {
        Form {
            Section("Transkription") {
                modelPicker
                languagePicker
            }

            Section("Shortcut") {
                KeyboardShortcuts.Recorder("Aufnahme-Hotkey", name: .toggleRecording)
            }

            Section("Ollama-Grammatikkorrektur") {
                Toggle("Aktivieren", isOn: $appState.ollamaEnabled)

                if appState.ollamaEnabled {
                    Picker("Modell", selection: $appState.ollamaModel) {
                        ForEach(ollamaModels, id: \.self) { Text($0).tag($0) }
                    }
                    Text("Ollama muss lokal laufen (localhost:11434). Fügt ~1–3s Latenz hinzu.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("System") {
                Toggle("Beim Login starten", isOn: launchAtLoginBinding)
                Toggle("AI-Enhancement (Füllwörter filtern)", isOn: $appState.enhancementEnabled)
            }
        }
        .formStyle(.grouped)
        .frame(width: 420)
        .padding(.vertical, 8)
        .task {
            let fetched = await OllamaEnhancer.availableModels()
            if !fetched.isEmpty { ollamaModels = fetched }
        }
    }

    // MARK: - Subviews

    private var modelPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Picker("Modell", selection: $appState.selectedModel) {
                ForEach(ModelManager.availableModels, id: \.id) { model in
                    Text(model.label).tag(model.id)
                }
            }

            if case .loading = appState.modelState {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Modell wird geladen…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if case .failed(let msg) = appState.modelState {
                Text("Fehler: \(msg)")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if case .ready = appState.modelState {
                Text("Modell bereit")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                Text("Wird beim nächsten Start der Aufnahme geladen.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var languagePicker: some View {
        Picker("Sprache", selection: $appState.selectedLanguage) {
            Text("Deutsch").tag("de")
            Text("Englisch").tag("en")
            Text("Französisch").tag("fr")
            Text("Spanisch").tag("es")
            Text("Italienisch").tag("it")
            Text("Portugiesisch").tag("pt")
        }
    }
}

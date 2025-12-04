import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ThemeService {
  private readonly THEME_KEY = 'theme_preference';
  public darkModeSubject = new BehaviorSubject<boolean>(false);
  public darkMode$: Observable<boolean> = this.darkModeSubject.asObservable();

  constructor() {
    this.initializeTheme();
    this.listenForFlutterThemeChanges();
  }

  private initializeTheme(): void {
    const savedTheme = localStorage.getItem(this.THEME_KEY);
    if (savedTheme) {
      const isDark = savedTheme === 'dark';
      this.darkModeSubject.next(isDark);
      this.applyTheme(isDark);
    } else {
      // Check system preference
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      this.darkModeSubject.next(prefersDark);
      this.applyTheme(prefersDark);
    }
  }

  private listenForFlutterThemeChanges(): void {
    // Listen for theme changes from Flutter app
    window.addEventListener('flutter-theme-changed', ((event: CustomEvent) => {
      const isDark = event.detail?.isDark ?? false;
      // Only update if different from current state to avoid loops
      if (this.darkModeSubject.value !== isDark) {
        this.setTheme(isDark);
      }
    }) as EventListener);
  }

  toggleTheme(): void {
    const currentMode = this.darkModeSubject.value;
    const newMode = !currentMode;
    this.darkModeSubject.next(newMode);
    this.applyTheme(newMode);
    localStorage.setItem(this.THEME_KEY, newMode ? 'dark' : 'light');
  }

  setTheme(isDark: boolean): void {
    this.darkModeSubject.next(isDark);
    this.applyTheme(isDark);
    localStorage.setItem(this.THEME_KEY, isDark ? 'dark' : 'light');
  }

  isDarkMode(): boolean {
    return this.darkModeSubject.value;
  }

  private applyTheme(isDark: boolean): void {
    if (isDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }
}


import { Component, signal, ViewEncapsulation } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Header } from './components/header/header';
import { Sidebar } from './components/sidebar/sidebar';
import { Footer } from './components/footer/footer';

@Component({
  imports: [Header, Sidebar, Footer, RouterOutlet],
  encapsulation: ViewEncapsulation.None,
  selector: 'app-root',
  styleUrl: './app.css',
  templateUrl: './app.html',
})
export class App {
  protected readonly title = signal('painel-senai');
  protected readonly sidebarOpen = signal(true);

  protected toggleSidebar() {
    this.sidebarOpen.update((isOpen) => !isOpen);
  }
}

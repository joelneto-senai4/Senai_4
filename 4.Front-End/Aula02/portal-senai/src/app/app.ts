import { Component, HostListener, signal } from '@angular/core';
import { Header } from './componentes/header/header';
import { Sidebar } from './componentes/sidebar/sidebar';
import { HeroBanner } from './componentes/hero-banner/hero-banner';
import { CardProduct } from './componentes/card-product/card-product';
import { Footer } from './componentes/footer/footer';

@Component({
  imports: [Header, Sidebar, HeroBanner, CardProduct, Footer],
  selector: 'app-root',
  styleUrl: './app.css',
  templateUrl: './app.html',
})
export class App {
  protected readonly title = signal('portal-senai');

  private activeResize: 'header' | 'sidebar' | 'hero' | 'footer' | null = null;
  private startPosition = 0;
  private startSize = 0;

  startResize(event: PointerEvent): void {
    const handle = (event.currentTarget as HTMLElement).dataset['resize'];
    if (!handle) {
      return;
    }

    const pageShell = (event.currentTarget as HTMLElement).closest('.page-shell') as HTMLElement | null;
    if (!pageShell) {
      return;
    }

    const target = this.getResizeTarget(pageShell, handle);
    if (!target) {
      return;
    }

    this.activeResize = handle as typeof this.activeResize;
    this.startPosition = this.isVerticalResize() ? event.clientX : event.clientY;
    this.startSize = this.isVerticalResize() ? target.getBoundingClientRect().width : target.getBoundingClientRect().height;
    (event.currentTarget as HTMLElement).setPointerCapture(event.pointerId);
    event.preventDefault();
  }

  @HostListener('document:pointermove', ['$event'])
  resize(event: PointerEvent): void {
    if (!this.activeResize) {
      return;
    }

    const pageShell = document.querySelector<HTMLElement>('.page-shell');
    if (!pageShell) {
      return;
    }

    const position = this.isVerticalResize() ? event.clientX : event.clientY;
    const change = position - this.startPosition;
    const minimum = this.getMinimumSize();
    const direction = this.activeResize === 'footer' ? -1 : 1;
    const maximum = this.getMaximumSize(pageShell);
    const size = Math.min(maximum, Math.max(minimum, this.startSize + change * direction));
    const property = `--${this.activeResize}-size`;
    pageShell.style.setProperty(property, `${size}px`);
  }

  @HostListener('document:pointerup')
  stopResize(): void {
    this.activeResize = null;
  }

  private isVerticalResize(): boolean {
    return this.activeResize === 'sidebar';
  }

  private getMinimumSize(): number {
    return this.activeResize === 'sidebar' || this.activeResize === 'hero' ? 150 : 54;
  }

  private getMaximumSize(pageShell: HTMLElement): number {
    const contentLayout = pageShell.querySelector<HTMLElement>('.content-layout');
    const footer = pageShell.querySelector<HTMLElement>('app-footer');
    const header = pageShell.querySelector<HTMLElement>('app-header');
    const shellStyle = getComputedStyle(pageShell);
    const verticalPadding = parseFloat(shellStyle.paddingTop) + parseFloat(shellStyle.paddingBottom);
    const viewportHeight = window.innerHeight;
    const contentMinimumHeight = 320;
    const gridSpacing = 60;

    if (this.activeResize === 'sidebar' && contentLayout) {
      return Math.max(this.getMinimumSize(), contentLayout.clientWidth - 330);
    }
    if (this.activeResize === 'hero' && contentLayout) {
      return Math.max(this.getMinimumSize(), contentLayout.clientHeight - 170);
    }
    if (this.activeResize === 'header' && footer) {
      return Math.max(this.getMinimumSize(), viewportHeight - verticalPadding - footer.offsetHeight - contentMinimumHeight - gridSpacing);
    }
    if (this.activeResize === 'footer' && header) {
      return Math.max(this.getMinimumSize(), viewportHeight - verticalPadding - header.offsetHeight - contentMinimumHeight - gridSpacing);
    }
    return this.getMinimumSize();
  }

  private getResizeTarget(pageShell: HTMLElement, handle: string): HTMLElement | null {
    if (handle === 'header') {
      return pageShell.querySelector('app-header');
    }
    if (handle === 'sidebar') {
      return pageShell.querySelector('app-sidebar');
    }
    if (handle === 'hero') {
      return pageShell.querySelector('app-hero-banner');
    }
    return pageShell.querySelector('app-footer');
  }
}

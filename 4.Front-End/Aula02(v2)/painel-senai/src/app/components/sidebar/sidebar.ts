import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { Component, input, output } from '@angular/core';
import { RouterLink } from '@angular/router';
import { House, Mail, Package } from 'lucide';

@Component({
  imports: [RouterLink],
  selector: 'app-sidebar',
  styleUrl: './sidebar.css',
  templateUrl: './sidebar.html',
})
export class Sidebar {
  readonly isOpen = input(true);
  readonly navigationItems: { label: string; href: string; icon: SafeHtml }[];

  constructor(private readonly sanitizer: DomSanitizer) {
    this.navigationItems = [
      { label: 'Início', href: '/', icon: this.renderIcon(House) },
      { label: 'Cursos', href: '/cursos', icon: this.renderIcon(Package) },
      { label: 'Contato', href: '/contato', icon: this.renderIcon(Mail) },
    ];
  }

  private renderIcon(
    icon: Array<[string, Record<string, string | number | undefined>]>,
  ) {
    const content = icon
      .map(([tag, attributes]) => {
        const renderedAttributes = Object.entries(attributes)
          .filter(([, value]) => value !== undefined)
          .map(([name, value]) => `${name}="${value}"`)
          .join(' ');
        return `<${tag} ${renderedAttributes}></${tag}>`;
      })
      .join('');

    return this.sanitizer.bypassSecurityTrustHtml(
      `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${content}</svg>`,
    );
  }
}

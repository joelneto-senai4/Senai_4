import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { Component, computed, input, output, signal } from '@angular/core';
import { Router } from '@angular/router';
import { RouterLink } from '@angular/router';
import { Menu, Search, UserRound } from 'lucide';

@Component({
  imports: [RouterLink],
  selector: 'app-header',
  styleUrl: './header.css',
  templateUrl: './header.html',
})
export class Header {
  readonly sidebarOpen = input(true);
  readonly toggleSidebar = output<void>();
  readonly searchOpen = signal(false);
  readonly searchQuery = signal('');
  readonly searchIcon: SafeHtml;
  readonly userIcon: SafeHtml;
  readonly menuIcon: SafeHtml;
  readonly suggestions = [
    'Cursos técnicos',
    'Processo seletivo',
    'Cursos de automação industrial',
    'Unidades SENAI',
    'Bolsas de estudo',
  ];
  readonly filteredSuggestions = computed(() => {
    const query = this.searchQuery().trim().toLowerCase();

    if (!query) {
      return this.suggestions;
    }

    return this.suggestions.filter((suggestion) =>
      suggestion.toLowerCase().includes(query),
    );
  });

  constructor(private readonly sanitizer: DomSanitizer, private readonly router: Router) {
    this.searchIcon = this.renderIcon(Search);
    this.userIcon = this.renderIcon(UserRound);
    this.menuIcon = this.renderIcon(Menu);
  }

  toggleSearch() {
    this.searchOpen.update((isOpen) => !isOpen);

    if (!this.searchOpen()) {
      this.searchQuery.set('');
    }
  }

  closeSearch() {
    this.searchOpen.set(false);
    this.searchQuery.set('');
  }

  updateSearch(event: Event) {
    this.searchQuery.set((event.target as HTMLInputElement).value);
  }

  openStudentArea() {
    void this.router.navigate(['/sou-aluno']);
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

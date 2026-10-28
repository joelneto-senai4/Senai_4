import { Component, inject } from '@angular/core';
import { RouterLink, ActivatedRoute } from '@angular/router';

export type PageCard = { title: string; text: string; label?: string };
export type InstitutionalPageData = { kicker: string; title: string; intro: string; cards: PageCard[]; actionLabel?: string; actionLink?: string };

@Component({
  imports: [RouterLink],
  selector: 'app-institutional-page',
  styleUrl: './institutional-page.css',
  templateUrl: './institutional-page.html',
})
export class InstitutionalPage {
  readonly route = inject(ActivatedRoute);
  readonly page = this.route.snapshot.data as InstitutionalPageData;
}

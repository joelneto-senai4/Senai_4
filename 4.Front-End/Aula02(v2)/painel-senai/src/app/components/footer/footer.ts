import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { siFacebook, siInstagram, siYoutube, SimpleIcon } from 'simple-icons';

@Component({
  imports: [RouterLink],
  selector: 'app-footer',
  styleUrl: './footer.css',
  templateUrl: './footer.html',
})
export class Footer {
  readonly socialLinks: { label: string; icon: SafeHtml }[];

  constructor(private readonly sanitizer: DomSanitizer) {
    this.socialLinks = [
      { label: 'Instagram', icon: this.renderIcon(siInstagram) },
      { label: 'Facebook', icon: this.renderIcon(siFacebook) },
      { label: 'YouTube', icon: this.renderIcon(siYoutube) },
    ];
  }

  private renderIcon(icon: SimpleIcon) {
    return this.sanitizer.bypassSecurityTrustHtml(
      `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="${icon.path}"></path></svg>`,
    );
  }
}

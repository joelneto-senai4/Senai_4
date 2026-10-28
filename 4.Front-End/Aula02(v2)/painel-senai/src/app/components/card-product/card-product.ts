import { Component, input } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  imports: [RouterLink],
  selector: 'app-card-product',
  styleUrl: './card-product.css',
  templateUrl: './card-product.html',
})
export class CardProduct {
  readonly title = input('Curso');
  readonly image = input('');
  readonly category = input('Formação profissional');
  readonly description = input('Desenvolva competências para o futuro da indústria.');
}

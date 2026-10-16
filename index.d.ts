export interface Band {
  id: string;
  name: string;
  logo: string | null;
  images: string[];
}

export const bands: Band[];

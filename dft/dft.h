/*
 * Copyright (c) 2002 Matteo Frigo
 * Copyright (c) 2002 Steven G. Johnson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

/* $Id: dft.h,v 1.2 2002-06-02 23:49:03 athena Exp $ */

#include "ifftw.h"

/* problem.c: */
typedef struct {
     problem super;
     tensor sz, vecsz;
     R *ri, *ii, *ro, *io;
} problem_dft;

int fftw_problem_dft_p(const problem *p);
#define DFTP fftw_problem_dft_p  /* shorthand */

/* solve.c: */
void fftw_dft_solve(plan *ego_, const problem *p_);

/* plan.c: */
typedef void (*dftapply) (plan *ego, R *ri, R *ii, R *ro, R *io);

typedef struct {
     plan super;
     dftapply apply;
} plan_dft;

plan *fftw_mkplan_dft(size_t size, const plan_adt *adt, dftapply apply);

#define MKPLAN_DFT(type, adt, apply) \
  (type *)fftw_mkplan_dft(sizeof(type), adt, apply)

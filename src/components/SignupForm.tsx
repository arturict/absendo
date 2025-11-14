import React, { useState } from 'react';
import { supabase} from "../supabaseClient.ts";

function SignupForm() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [agreed, setAgreed] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');

        if (!email || !password) {
            setError('Bitte fülle alle Felder aus.');
            return;
        }

        try {
            const { error: signUpError } = await supabase.auth.signUp({ 
                email, 
                password,
                options: {
                    emailRedirectTo: 'https://absendo.artur.engineer/welcome',
                }
            });
            if (signUpError) throw signUpError;
            window.location.href = '/email-verification';
        } catch (err: unknown) {
            setError(err instanceof Error ? err.message : 'Registrierung fehlgeschlagen.');
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-base-100">
            <div className="card w-96 bg-base-200 shadow-xl">
                <div className="card-body mb-0">
                    <h2 className="card-title text-2xl font-bold mb-4">
                        Hallo 👋, registriere dich, um fortzufahren
                    </h2>

                    <form
                        className="form-control mb-4"
                        onSubmit={handleSubmit}
                    >
                        <div className="form-control mb-4">
                            <label className="label">
                                <span className="label-text">Email</span>
                            </label>
                            <input
                                onChange={(e) => setEmail(e.target.value)}
                                type="email"
                                placeholder="Email"
                                className="input input-bordered w-full"
                            />
                        </div>

                        <div className="form-control mb-4">
                            <label className="label">
                                <span className="label-text">Password</span>
                            </label>
                            <input
                                onChange={(e) => setPassword(e.target.value)}
                                type="password"
                                placeholder="Password"
                                className="input input-bordered w-full"
                            />
                        </div>

                        {error ? (
                            <div role="alert" className="alert alert-error mb-4">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>{error}</span>
                            </div>
                        ) : null}

                        <button className="btn btn-primary w-full" disabled={!agreed}>
                            Sign up
                            <svg
                                className="w-5 h-5 ml-2"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    strokeWidth="2"
                                    d="M9 5l7 7-7 7"
                                />
                            </svg>
                        </button>

                        <div className="form-control mt-4">
                            <label className="label cursor-pointer">
                                <input type="checkbox" checked={agreed} onChange={() => setAgreed(!agreed)} className="checkbox checkbox-primary" />
                                <span className="label-text ml-2">Ich stimme den <a href="/datenschutz" className="link">Datenschutzbestimmungen</a> zu</span>
                            </label>
                        </div>
                        <div className="text-center mt-6">
                            <p className="text-xs">
                                <p>Du hast schon einen Account? <a href="/login" className="link">Log in!</a></p>
                            </p>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    );
}
export default SignupForm;
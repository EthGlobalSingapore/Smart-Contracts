"use client";
import {
  useAuthModal,
  useLogout,
  useSignerStatus,
  useUser,
} from "@account-kit/react";
import MyOpSenderComponent from "./sendop";
import SwapChain from "./changeChain";
import ReadAccount from "./getAccount";
import SetGreetingComponent from "./sendop2";
// import { DynamicWidget } from "@dynamic-labs/sdk-react-core";
// import DynamicTest from "./dynamic";


export default function Home() {
  const user = useUser();
  const { openAuthModal } = useAuthModal();
  const signerStatus = useSignerStatus();
  const { logout } = useLogout();

  console.log(signerStatus.status);

  return (
    <main className="flex min-h-screen flex-col items-center p-24 gap-4 justify-center text-center">
      {signerStatus.isInitializing ? (
        <>Loading...</>
      ) : user ? (
        <div className="flex flex-col gap-2 p-2">
          <p className="text-xl font-bold">Success!</p>
          Logged in as {user.email ?? "anon"}.
          <button className="btn btn-primary mt-6" onClick={() => logout()}>
            Log out
          </button>
        </div>
      ) : (
        <button className="btn btn-primary" onClick={openAuthModal}>
          Login
        </button>
      )}
      <SetGreetingComponent />
      <MyOpSenderComponent />
      <SwapChain />
      <ReadAccount />
      {/* <DynamicWidget />
      <DynamicTest /> */}
    </main>
  );
}

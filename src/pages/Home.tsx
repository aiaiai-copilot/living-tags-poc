function Home() {
  return (
    <div className="space-y-8">
      <div className="rounded-lg border bg-card p-6 text-card-foreground shadow-sm">
        <h2 className="text-xl font-semibold mb-2">Welcome to Living Tags PoC</h2>
        <p className="text-muted-foreground">
          This is a proof of concept for AI-powered semantic tagging of Russian jokes and anecdotes.
        </p>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <div className="rounded-lg border bg-card p-6 text-card-foreground shadow-sm">
          <h3 className="font-semibold mb-2">Add Texts</h3>
          <p className="text-sm text-muted-foreground">
            Add Russian jokes and anecdotes to the database
          </p>
        </div>

        <div className="rounded-lg border bg-card p-6 text-card-foreground shadow-sm">
          <h3 className="font-semibold mb-2">Auto-Tag</h3>
          <p className="text-sm text-muted-foreground">
            Use Claude AI to automatically analyze and tag texts
          </p>
        </div>

        <div className="rounded-lg border bg-card p-6 text-card-foreground shadow-sm">
          <h3 className="font-semibold mb-2">Search & Browse</h3>
          <p className="text-sm text-muted-foreground">
            Search texts by tags and semantic meaning
          </p>
        </div>
      </div>
    </div>
  )
}

export default Home

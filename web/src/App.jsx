import { useState, useEffect } from 'react'

export default function App() {
  const [time, setTime] = useState(new Date())
  const [hostname, setHostname] = useState('Loading...')

  useEffect(() => {
    const timer = setInterval(() => setTime(new Date()), 1000)
    return () => clearInterval(timer)
  }, [])

  useEffect(() => {
    fetch('/api/hostname')
      .then(res => res.text())
      .then(data => setHostname(data))
      .catch(() => setHostname('Unknown'))
  }, [])

  return (
    <div style={styles.container}>
      <div style={styles.gradient} />
      <div style={styles.orb1} />
      <div style={styles.orb2} />
      <div style={styles.orb3} />
      <div style={styles.orb4} />
      <div style={styles.content}>
        <h1 style={styles.text}>Demo AWS and ANSIBLE</h1>
        <div style={styles.clock}>
          {time.toLocaleTimeString()}
        </div>
        <div style={styles.hostname}>
          Instance: {hostname}
        </div>
      </div>
    </div>
  )
}

const styles = {
  container: {
    position: 'relative',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100vh',
    background: '#0a0a0f',
    overflow: 'hidden',
  },
  gradient: {
    position: 'absolute',
    inset: 0,
    background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f0f1e 100%)',
    animation: 'gradientShift 15s ease infinite',
  },
  orb1: {
    position: 'absolute',
    width: '600px',
    height: '600px',
    borderRadius: '50%',
    background: 'radial-gradient(circle, rgba(99,102,241,0.4) 0%, rgba(99,102,241,0.1) 40%, transparent 70%)',
    top: '-200px',
    left: '-200px',
    filter: 'blur(60px)',
    animation: 'float1 20s ease-in-out infinite',
  },
  orb2: {
    position: 'absolute',
    width: '500px',
    height: '500px',
    borderRadius: '50%',
    background: 'radial-gradient(circle, rgba(236,72,153,0.35) 0%, rgba(236,72,153,0.15) 40%, transparent 70%)',
    bottom: '-150px',
    right: '-150px',
    filter: 'blur(50px)',
    animation: 'float2 18s ease-in-out infinite',
  },
  orb3: {
    position: 'absolute',
    width: '450px',
    height: '450px',
    borderRadius: '50%',
    background: 'radial-gradient(circle, rgba(34,211,238,0.3) 0%, rgba(34,211,238,0.1) 40%, transparent 70%)',
    top: '40%',
    left: '60%',
    filter: 'blur(55px)',
    animation: 'float3 16s ease-in-out infinite',
  },
  orb4: {
    position: 'absolute',
    width: '350px',
    height: '350px',
    borderRadius: '50%',
    background: 'radial-gradient(circle, rgba(167,139,250,0.25) 0%, rgba(167,139,250,0.1) 40%, transparent 70%)',
    top: '15%',
    right: '20%',
    filter: 'blur(45px)',
    animation: 'float4 22s ease-in-out infinite',
  },
  content: {
    position: 'relative',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '2rem',
  },
  text: {
    fontSize: 'clamp(3rem, 10vw, 8rem)',
    fontWeight: '800',
    fontFamily: "'Segoe UI', system-ui, sans-serif",
    letterSpacing: '-0.02em',
    background: 'linear-gradient(135deg, #fff 0%, rgba(255,255,255,0.8) 50%, rgba(255,255,255,0.6) 100%)',
    WebkitBackgroundClip: 'text',
    WebkitTextFillColor: 'transparent',
    backgroundClip: 'text',
    filter: 'drop-shadow(0 0 60px rgba(99,102,241,0.5))',
    userSelect: 'none',
    textAlign: 'center',
    margin: 0,
  },
  clock: {
    fontSize: 'clamp(2rem, 6vw, 4rem)',
    fontWeight: '600',
    fontFamily: "'Courier New', monospace",
    color: 'rgba(255,255,255,0.9)',
    textShadow: '0 0 30px rgba(99,102,241,0.6), 0 0 60px rgba(236,72,153,0.4)',
    letterSpacing: '0.1em',
    userSelect: 'none',
  },
  hostname: {
    fontSize: 'clamp(1rem, 3vw, 1.5rem)',
    fontWeight: '500',
    fontFamily: "'Courier New', monospace",
    color: 'rgba(255,255,255,0.7)',
    textShadow: '0 0 20px rgba(34,211,238,0.5)',
    letterSpacing: '0.05em',
    userSelect: 'none',
    marginTop: '1rem',
  },
}

const styleTag = document.createElement('style')
styleTag.textContent = `
  @keyframes gradientShift {
    0%, 100% {
      filter: hue-rotate(0deg) brightness(1);
    }
    50% {
      filter: hue-rotate(20deg) brightness(1.1);
    }
  }

  @keyframes float1 {
    0%, 100% {
      transform: translate(0, 0) scale(1) rotate(0deg);
    }
    33% {
      transform: translate(80px, -60px) scale(1.15) rotate(120deg);
    }
    66% {
      transform: translate(-40px, 80px) scale(0.95) rotate(240deg);
    }
  }

  @keyframes float2 {
    0%, 100% {
      transform: translate(0, 0) scale(1) rotate(0deg);
    }
    33% {
      transform: translate(-70px, 50px) scale(1.1) rotate(-120deg);
    }
    66% {
      transform: translate(60px, -70px) scale(0.9) rotate(-240deg);
    }
  }

  @keyframes float3 {
    0%, 100% {
      transform: translate(0, 0) scale(1);
    }
    25% {
      transform: translate(-60px, -80px) scale(1.2);
    }
    50% {
      transform: translate(70px, 60px) scale(0.85);
    }
    75% {
      transform: translate(40px, -50px) scale(1.1);
    }
  }

  @keyframes float4 {
    0%, 100% {
      transform: translate(0, 0) scale(1) rotate(0deg);
    }
    40% {
      transform: translate(90px, 70px) scale(1.15) rotate(180deg);
    }
    80% {
      transform: translate(-80px, -60px) scale(0.9) rotate(360deg);
    }
  }
`
document.head.appendChild(styleTag)
